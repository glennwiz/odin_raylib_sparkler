Todo:
Wireworld Cellular Automaton Algorithm

A Wireworld cell can be in one of four different states: Empty , Electron head (), Electron tail , and Connector

As in all cellular automate, time proceeds in discrete steps called generations. Cells behave as follows:

    Empty → Empty
    Electron head → Electron tail
    Electron tail → Connector
    Connector
        → Electron head if exactly one or two of the neighboring cells are electron heads
        → remains connector otherwise

In the rules above, neighboring means one cell away in any direction, both orthogonal and diagonal.