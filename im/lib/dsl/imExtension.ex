defmodule Im.DSL.ImExtension do
  @process %Spark.Dsl.Entity{
    name: :process,
    describe: "A process that sends and receives messages.",
    args: [:identifier],
    target: Im.Process,
    schema: [
      identifier: [
        type: :string
      ],
      state: [
        type: {:map, :string, {:tuple, [:atom, :string]}},
        doc: "State of the process, defined as a map."
      ],
      run: [
        type: {:list, {:or, [
          {:tuple, [:atom, :keyword_list]},
        ]}},
        doc: "List of actions to perform, including send and receive."
      ]
    ]#
    #transform: {Im.DSL.Entities.Process, :transform_run, []}
  }

  @root %Spark.Dsl.Section{
    top_level?: true,
    name: :root,
    describe: "Root section defining the message type and processes.",
    schema: [
      messageType: [
        type: {:or, [:atom, :string]},
        required: true,
        doc: "The type of messages the system handles. Every message has to be this type."
      ]
    ],
    entities: [
      @process
    ]
  }

  use Spark.Dsl.Extension, sections: [@root]

end
