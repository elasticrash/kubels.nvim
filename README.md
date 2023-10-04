# kubels
## Description

This is a really basic Kubernetes plugin that I wrote for telescope.

This is mostly to see how I can write a useful plugin in telescope and get a little bit familiar with lua.

It doesn't do much. 

* Upon launch, you'll be presented with a list of contexts available on your machine.
* When you select a context you can seamlessly switch between different contexts within your current terminal session.
* The plugin will then display all the namespaces associated with the chosen context.
* Upon selecting a namespace you get a see a list of pods
* When you select a pod you get the `kubectl describe pod` output in a new buffer

# How to use

Simply add the following line to your Lua configuration:
`require('telescope').load_extension "kubels"`
