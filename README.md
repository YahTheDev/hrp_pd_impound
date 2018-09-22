## PD IMPOUND

* I'm not sure if I will expand it in the future, if you do find any bugs though please let me know.
* This script does not stop players from spawning vehicles elsewhere, you'll probably want to disable the spawning of vehicles in another script if the user's plate is found in the impounded table.
* You're allowed to impound if you either have the police job, or the mecano job.
* There currently are no markers. The default impound location is Popular Street PD. At the front entrance you can unimpound, and in the parking lot garage next to it ( the one you can drive into ) you can impound vehicles.
* Impounded vehicles are bound to steam Id's.


![](https://i.imgur.com/kPUE6CA.jpg)
Impound vehicles as an officer or mechanic!

![](https://i.imgur.com/4QSzi3j.jpg)
Retrieve your impounded vehicles here!

![](https://i.imgur.com/If6hFWr.jpg)
As an officer or mechanic you can unlock specific vehicles so they can be retrieved.


Dependencies:
- All the usual ESX stuff.

Warning:
- This script has not been tested on any public servers, if you use it you do so at your own risk. If you'd like to test this script, please share the results. 
- **I will not be responsible for any damage this script could cause.**

Known limitations:
- When a player switches jobs they have to relog in order to be able to use these functionalities. This is because playerdata is only loaded at the start. This is the way it is for now.
- If a user registred during this session the functionalities also seem to run into some problems, probably because of the same reason as the previous point.

Any suggestions, help / tips or bug reports are welcome.

- Horizon

## Please excuse the crapy coding style...
I've not worked with lua a lot, I might clean it up in the future.. Also might not, after all im lazy.. and it works..
Anything else is a feature :)
