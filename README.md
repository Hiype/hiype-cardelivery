# FiveM car delivery script

FiveM resource for servers with QbCore Framework.

Start a mission for a car delivery, steal the car, drive it to the destination, profit.<br>
Pretty simple so far, further updates coming soon.

**Development still in progress**<br>
📽️⬇️ Check the video below! 📽️⬇️

[![Preview video](https://i.imgur.com/gJTgDYv.jpg)](http://www.youtube.com/watch?v=MU_RDg1ahBc "FiveM QBCore Car Delivery FREE Script")

## Features

- Payout based on vehicle condition (Engine, Body, Level)
- Very configurable
- Cooldown between each taken job
- Vehicles spawn either parked or driving around (Soon)
- Very basic rank system, nothing changes yet
- Possible cop car chase when the car is stolen
- **NEW** Rank system with better cars spawning the more xp you get
- **NEW** Chat commands for checking current level by /deliveryxp
- **NEW** Admin rank editing options with /cardeliveryxp (option) (number)

## Requirements

- [QbCore framework](https://github.com/qbcore-framework)

## Setup

1. Download or clone this repository inside your resources folder
2. Remove the "-main" part from folder name
3. Add a line to your server.cfg file -> **ensure hiype-cardelivery**
4. Add a line inside [qb] -> qb-core -> server -> player.lua

```lua
   PlayerData.metadata['cardeliveryxp'] = PlayerData.metadata['cardeliveryxp'] or 0
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;An example image can be found at the bottom of this section.<br>

5. If your server is running, remember to either restart your server or do **/refresh** and also **/start hiype-cardelivery**

![Enter this line](https://i.imgur.com/hae5hLd.png)

## Instructions

To start the job, go to the location seen on the map below.

![Map](https://i.imgur.com/4xeQvGS.png)

Once there, go next to the NPC and press E key on your keyboard to start the job. An objective will automatically show up.

![Job start location](https://i.imgur.com/b4coTdR.png)

Follow the objective, use any lockpick to open the car and hotwire if necessary.<br>
Drive to the destination. Beware, if the car is destroyed, job will **fail**!<br>
Once you arrive at the destination, stop the car inside the objective blip on mini map. Job will finish and you will get paid depending on distance driven and condition of the car.

## Possible issues

- Billion dollar payout? Multiple reports, but unable to recreate the problem, if anyone encounters this please add more information on how to recreate this. :)

## Support

If you wish to support me in any way, you can do so through this link -> [Streamelements donos](https://streamelements.com/hiype/tip)<br>
This link will redirect you to a Streamelements donation page which shows the donation on my youtube stream if I'm live<br>
P.S Im rarely live and this was just easier to do
