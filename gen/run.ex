scenario = "return-plus-one"
folder = "generated/#{scenario}"
:ok = File.mkdir_p(folder)

Code.compile_file("conf.ex")
Code.compile_file("genex.ex")
Code.compile_file("genmcrl2.ex")
conf = Conf.getConf()[scenario]
GenEx.run(folder, conf)
GenMcrl2.run(folder, conf)
Code.compile_file("#{folder}/User.ex")
Code.compile_file("#{folder}/Mach.ex")
Code.compile_file("#{folder}/Main.ex")
Main.run()
