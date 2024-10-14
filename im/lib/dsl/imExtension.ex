defmodule Im.DSL.ImExtension do

  @messageType {:or, [:atom, :string, :integer]}

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
        type: @messageType
      ]
    ],
  }

  @receivecase %Spark.Dsl.Entity{
    name: :match,
    describe: "Receive case.",
    target: Im.Commands.ReceiveCase,
    args: [:condition],
    schema: [
      condition: [
        type: @messageType,
      ]
    ],

    entities: [body: [@sendcmd]]
  }

  @choicecmd %Spark.Dsl.Entity{
    name: :choice,
    describe: "Non deterministic choice.",
    target: Im.Commands.Choice,
    args: [:label],
    schema: [
      label: [
        type: :string
      ],
    ],
    entities: [body: [@sendcmd]]
  }

  @receivecmd %Spark.Dsl.Entity{
    name: :rcv,
    describe: "Receive command.",
    target: Im.Commands.Receive,
    args: [:value],
    schema: [
      value: [
        type: {:or, [:string, {:tuple, [{:or, [:string, :nil]}, :string]}]},
        doc: "Variable name for received value",
      ]
    ],
    entities: [body: [@receivecase, @sendcmd, @choicecmd]]
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
