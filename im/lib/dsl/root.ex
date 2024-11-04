defmodule Im.Dsl.Root do

  use Spark.Dsl.Extension, sections: [%Spark.Dsl.Section{
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
      Im.Dsl.Process.process,
      Im.Dsl.SubProcess.process
    ]
  }]

end
