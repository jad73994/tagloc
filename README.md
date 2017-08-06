# tagloc


There are four scripts. The rest are functions.



switch_experiment.m will collect OFDM channels.
gfsk_usrp.m will collect gfsk channels.
vna_experiment.m will collect VNA channels.

All three of those will switch through antennas automatically. They rely on the hardware setup being correct, and they rely on two terminals being open to talk to the USRPs. Open two terminals, provide a sudo password, run tty to get the terminals' files and then change them in the rxtty and txtty variables.



analyze_data.m will load saved data from a VNA experiment and do localization using those channels.
