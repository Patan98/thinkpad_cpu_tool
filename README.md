# Thinkpad CPU tool
Simple bash script to manage CPU power setting and prevent overheating using intel pstate. <br />

## Idea
The operation of the software is nsure on older Intel processor models (35W and 45W) optimal battery life and variable performance with just one click. <br />
Clearly with the new models, energy performance is already highly optimized, so use is recommended mainly on models with higher consumption. <br />

## Requirements
    # sudo apt install libttspico-utils

## Usage
The two folders: code and code_data should be placed in the user's home folder.

Be sure to replace YOURUSERNAME in cpu.sh with your actual username.

The script works interacting with /sys/devices/system/cpu/intel_pstate, so if this folder is located somewhere else for you, replace it in cpu.sh <br />
What the script actually does is dynamically modify this files to work as a CPU limiter, to always make it work at temperatures that do not damage it in the long run. <br />
If you are thinking that this function already exists built-in intel processors, at least for the old energy-hungry generations, it is more of an emergency system that activates at very high temperatures, but which in any case risks making the CPU work for a long time above 90 degrees. <br />

The script provides a scale composed of: <br />
37, 60, 70, 85, 100 <br />
Which are dynamically scaled if the temperature is too high, or re-established if the temperature decreases. <br />
The overheat temperature is 80 degrees, in that case the CPU power is scaled immediately. <br />
If the temperature is between 75 and 80 degrees there is a tolerance of 15 seconds, after which the script scales the CPU power if the temperature has not dropped. <br />
If the CPU has been scaled, it returns to its previous state after 15 seconds with temperature below 75 degrees. <br />

# EXAMPLE <br />
    # OVERHEATING 1
    #                                                     CURRENT
    # 0---------37---------60---------70---------85---------100
    #                                           NEW
    # 0---------37---------60---------70---------85---------100

    # OVERHEATING 2
    #                                          CURRENT
    # 0---------37---------60---------70---------85---------100
    #                                NEW
    # 0---------37---------60---------70---------85---------100


There are three execution arguments: <br />
1) Switch: Fast Process: Scales CPU to the next value (if it is at 100% it starts again from 37%). Depending on your desktop environment, you can assign the script execution to a key. <br />
2) Monitor: Continued Process: Enables temperature monitor and dynamically scales CPU based on temperature. <br />
3) Boost: Continuous process: for intense use, it increases the overheating margin to 85 degrees, after 5 seconds of temperature above this threshold, the boost mode deactivates and the monitor mode is re-established. <br />
 <br />
