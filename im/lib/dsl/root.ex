defmodule Dsl.Root do

  use Spark.Dsl.Extension, sections: [%Spark.Dsl.Section{
    top_level?: true,
    name: :root,
    describe: "Root section defining the message type and processes.",
    schema: [
      messageType: [
        type: {:or, [:atom, :string]},
        required: true,
        doc: "The type of messages the system handles. Every message has to be this type."
      ],
      # allowCrash: [
      #   type: :boolean,
      #   doc: "If crashing of the nodes is enabled."
      # ],
      lossyNetwork: [
        type: :boolean,
        doc: "If loosing messages in the network is enabled."
      ]
    ],
    entities: [
      Dsl.Entities.Process.process
    ]
  }]

end
