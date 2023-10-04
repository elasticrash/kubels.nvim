# kubels

This is a really basic plugin that I wrote for telescope. This is mostly to see how I can write a useful plugin in telescope and get a little bit familiar with lua.

It doesn't do much. 


* Basically on launch you get a list of context your machine has access to 
* When you select a context it switches context (this is the main reason I build this, to quickly change contexts withint neovim)
* Then gives you all the namespaces on that context
* When you select a namespace you get a list of pods
* When you select a pod you get the describe in a new buffer
