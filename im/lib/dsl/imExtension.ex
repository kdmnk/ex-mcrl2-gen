defmodule Im.DSL.ImExtension do
  @sendcmd %Spark.Dsl.Entity{
    name: :snd,
    describe: "Send command.",
    target: Im.Commands.Send,
    args: [:to, :message],
    schema: [
      to: [
        type: {:or, [:atom, :string]}
      ],
      message: [
        type: {:or, [:atom, :string, :integer]}
      ]
    ],
  }

  @receivecmd %Spark.Dsl.Entity{
    name: :rcv,
    describe: "Receive command.",
    target: Im.Commands.Receive,
    args: [:from, :message],
    schema: [
      from: [
        type: {:or, [:atom, :string]}
      ],
      message: [
        type: {:or, [:atom, :string, :integer]}
      ]
    ],
  }

  @process %Spark.Dsl.Entity{
    name: :process,
    describe: "A process that defines commands.",
    args: [:identifier, :state],
    target: Im.Process,
    schema: [
      identifier: [
        type: :atom
      ],
      state: [
        type: {:map, :string, {:tuple, [:atom, :atom]}},
        doc: "State of the process, defined as a map."
      ]
    ],
    entities: [run: [@sendcmd, @receivecmd]]
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
