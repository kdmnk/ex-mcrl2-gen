# Ex-Mcrl2-Gen
Project to generate Elixir code with mcrl2 specification 


# Title: 
Enhancing Model Checking in practice: analysing distributed systems in Elixir with mCRL2
//
Forbedring af modelkontrol i praksis: analyse af distribuerede systemer i Elixir med mCRL2

# Description: 
Elixir is a programming languages known for their robust support for concurrency, fault tolerance, and distributed computing. In such complex, distributed systems, understanding and ensuring the correctness of software behaviour is a complex challenge. Model checking, a formal verification technique, provides a powerful approach to rigorously analyse and verify system behaviour. mCRL2 is a formal specification language and toolset designed for specifying, analysing, and verifying concurrent systems and protocols.
However, writing specification in a language like this is considered complex and associated with a steep learning curve that discourage programmers from using formal methods in practice. Developers working with Elixir lacks modern, automated tools that can provide insights into their systems without requiring deep expertise in model checking.

Tools like etomcrl2 [1] and mcErlang [2] use complex techniques to analyse written program code. However, Steenman, E. [3] investigated a more lightweight approach by defining system specifications in a high-level language, which is automatically transformed into both a formal model in mCRL2 and an implementation in Java. Steenman demonstrated that using this high-level language to create formally verifiable code is feasible for simpler scenarios.

The goal of this project is to extend this approach to distributed protocols, focusing on how these systems would behave in real networks.
The ultimate goal is to create a development workflow that allows developers to define the semantics of distributed systems and generate an implementation in Elixir, while they can analyse and gain a deeper understanding of their systems through a generated specification in mCRL2.

By automating this analysis, developers can more easily ensure the reliability and correctness of their systems, leading to more robust and dependable software.

[1] Guo, Qiang and John Derrick. “Formally based tool support for model checking Erlang applications.” International Journal on Software Tools for Technology Transfer 13 (2011), 355-376.

[2] Lars-Åke Fredlund and Hans Svensson. 2007. "McErlang: a model checker for a distributed functional programming language." SIGPLAN Not. 42, 9 (September 2007), 125–136. https://doi.org/10.1145/1291220.1291171

[3] Steenman, Erik. “Agile Development using Formal Methods.” (2016).