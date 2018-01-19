require "test_helper"

class PathTest < Minitest::Spec


   # Activity.plan( track_color: :pink )
  it "accepts :track_color" do
    activity = Module.new do
      extend Activity[ Activity::Path, track_color: :"track_9" ]

      task task: T.def_task(:a), id: "report_invalid_result"
      task task: T.def_task(:b), id: "log_invalid_result"#, Output(Right, :success) => End("End.invalid_result", :invalid_result)
    end

    process, outputs, adds = activity.decompose

    Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.a>
#<Method: #<Module:0x>.a>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>
 {Trailblazer::Activity::Right} => #<End:track_9/:success>
#<End:track_9/:success>
}

    SEQ(adds).must_equal %{
[] ==> #<Start:default/nil>
 (success)/Right ==> :track_9
[:track_9] ==> #<Method: #<Module:0x>.a>
 (success)/Right ==> :track_9
 (failure)/Left ==> nil
[:track_9] ==> #<Method: #<Module:0x>.b>
 (success)/Right ==> :track_9
 (failure)/Left ==> nil
[:track_9] ==> #<End:track_9/:success>
 []
}
  end

  it "accepts :track_color and an explicit End" do
    activity = Module.new do
      extend Activity[ Activity::Path, track_color: :"track_9" ]

      task task: T.def_task(:a)
      task task: T.def_task(:b), id: "//b", Output(Activity::Right, :success) => End("End.invalid_result", :invalid_result)
    end

    process, outputs, adds = activity.decompose

    Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.a>
#<Method: #<Module:0x>.a>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>
 {Trailblazer::Activity::Right} => #<End:End.invalid_result/:invalid_result>
#<End:track_9/:success>

#<End:End.invalid_result/:invalid_result>
}

    SEQ(adds).must_equal %{
[] ==> #<Start:default/nil>
 (success)/Right ==> :track_9
[:track_9] ==> #<Method: #<Module:0x>.a>
 (success)/Right ==> :track_9
 (failure)/Left ==> nil
[:track_9] ==> #<Method: #<Module:0x>.b>
 (success)/Right ==> "//b-Trailblazer::Activity::Right"
 (failure)/Left ==> nil
[:track_9] ==> #<End:track_9/:success>
 []
["//b-Trailblazer::Activity::Right"] ==> #<End:End.invalid_result/:invalid_result>
 []
}
  end

  it "accepts :type and :magnetic_to" do
    activity = Module.new do
      extend Activity[ Activity::Path ]

      task task: T.def_task(:a), id: "A"
      task task: T.def_task(:b), id: "B", type: :End
      task task: T.def_task(:c), id: "D", magnetic_to: [] # start event
      task task: T.def_task(:d), id: "I", type: :End
      task task: T.def_task(:e), id: "G", magnetic_to: [] # start event
    end

    process, outputs, adds = activity.decompose

    Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.a>
#<Method: #<Module:0x>.a>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>

#<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.d>
#<Method: #<Module:0x>.d>

#<Method: #<Module:0x>.e>
 {Trailblazer::Activity::Right} => #<End:success/:success>
#<End:success/:success>
}
  end

  it "accepts :normalizer" do
    binary_plus_poles = Activity::Magnetic::DSL::PlusPoles.new.merge(
      Activity.Output(Activity::Right, :success) => nil,
      Activity.Output(Activity::Left, :failure) => nil )

    normalizer = ->(task, options) { [ task, { plus_poles: binary_plus_poles }, options, {} ] }

    activity = Module.new do
      extend Activity[ Activity::Path, normalizer: normalizer ]

      task T.def_task(:a)
      task T.def_task(:b), Output(:failure) => Path(end_semantic: :invalid) do
        task T.def_task(:c), Output(:failure) => End(:left, :left)
        task T.def_task(:k)#, Output(:success) => End("End.invalid_result", :invalid_result)
      end
      task T.def_task(:d) # no :id.
    end

    process, outputs, adds = activity.decompose

    Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.a>
#<Method: #<Module:0x>.a>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>
 {Trailblazer::Activity::Left} => #<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.d>
#<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.k>
 {Trailblazer::Activity::Left} => #<End:left/:left>
#<Method: #<Module:0x>.k>
 {Trailblazer::Activity::Right} => #<End:track_0./:invalid>
#<Method: #<Module:0x>.d>
 {Trailblazer::Activity::Right} => #<End:success/:success>
#<End:success/:success>

#<End:track_0./:invalid>

#<End:left/:left>
}
  end

  describe "Path()" do
    it "accepts Path()" do
      activity = Module.new do
        extend Activity[ Activity::Path ]

        task task: T.def_task(:a)
        task task: T.def_task(:b), id: "//b", Output(Activity::Left, :failure) => Path() do
          task task: T.def_task(:c)
          task task: T.def_task(:d)
        end
      end

      process, outputs, adds = activity.decompose

      Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.a>
#<Method: #<Module:0x>.a>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>
 {Trailblazer::Activity::Left} => #<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<End:success/:success>
#<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.d>
#<Method: #<Module:0x>.d>
 {Trailblazer::Activity::Right} => #<End:track_0./:success>
#<End:success/:success>

#<End:track_0./:success>
}

      SEQ(adds).must_equal %{
[] ==> #<Start:default/nil>
 (success)/Right ==> :success
[:success] ==> #<Method: #<Module:0x>.a>
 (success)/Right ==> :success
 (failure)/Left ==> nil
[:success] ==> #<Method: #<Module:0x>.b>
 (success)/Right ==> :success
 (failure)/Left ==> \"track_0.\"
["track_0."] ==> #<Method: #<Module:0x>.c>
 (success)/Right ==> "track_0."
 (failure)/Left ==> nil
["track_0."] ==> #<Method: #<Module:0x>.d>
 (success)/Right ==> "track_0."
 (failure)/Left ==> nil
[:success] ==> #<End:success/:success>
 []
["track_0."] ==> #<End:track_0./:success>
 []
}
    end

    it "accepts :task_builder in Path()" do
      activity = Module.new do
        extend Activity[ Activity::Path, task_builder: ->(task) {task} ]

        task T.def_task(:a)
        task T.def_task(:b), id: "//b", Output(Activity::Left, :failure) => Path() do
          task T.def_task(:c)
          task T.def_task(:d)
        end
      end

      process, outputs, adds = activity.decompose

      Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.a>
#<Method: #<Module:0x>.a>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>
 {Trailblazer::Activity::Left} => #<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<End:success/:success>
#<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.d>
#<Method: #<Module:0x>.d>
 {Trailblazer::Activity::Right} => #<End:track_0./:success>
#<End:success/:success>

#<End:track_0./:success>
}
    end

    it "accepts :end_semantic" do
      activity = Module.new do
        extend Activity[ Activity::Path ]

        task task: T.def_task(:b), Output(Activity::Left, :failure) => Path(end_semantic: :invalid) do
          task task: T.def_task(:c)
        end
        task task: T.def_task(:d)
      end

      process, outputs, adds = activity.decompose

      Cct(process).must_equal %{
#<Start:default/nil>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.b>
#<Method: #<Module:0x>.b>
 {Trailblazer::Activity::Left} => #<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<Method: #<Module:0x>.d>
#<Method: #<Module:0x>.c>
 {Trailblazer::Activity::Right} => #<End:track_0./:invalid>
#<Method: #<Module:0x>.d>
 {Trailblazer::Activity::Right} => #<End:success/:success>
#<End:success/:success>

#<End:track_0./:invalid>
}
    end
  end

end
