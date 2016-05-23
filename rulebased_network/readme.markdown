The network simulator is written in Matlab. We simulate a synchronous network. The time is divided into slots and slots are divided into three sub-slots. In the first sub-slot each router checks its input ports, in case there are packets, it asks the controller about which output port they should be. Subsequently routers send these packets to the queue of appropriate output port. Second sub-slot is when these packets are sent out of the queues to the links attached to the ports. In the third sub-slot, each router receives incoming packets from links attached to its input ports. 

The class Router simulates functionality of an switch/router. It does not implement routing logic, as it follows the SDN principles and relies on the controller to decide routing functionality for it. 

The class Node simulates a source/destination. A load parameter passed to a node 
