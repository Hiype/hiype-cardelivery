# FiveM car delivery script (Rewrite)
**This rewrite release might be less stable, if you want the old version, change the branch**

FiveM resource for servers with QbCore Framework.

Start a mission for a car delivery, steal the car, drive it to the destination, profit.<br>

📽️⬇️ Check the video below! 📽️⬇️

[![Preview video](https://i.imgur.com/gJTgDYv.jpg)](http://www.youtube.com/watch?v=MU_RDg1ahBc "FiveM QBCore Car Delivery FREE Script")

## Features

- Payout based on vehicle condition (Engine, Body, Rank)
- Very configurable
- Cooldown between each taken job
- Possible cop car chase when the car is stolen
- Rank system with better cars spawning the more xp you get
- Chat commands for checking current level
- Admin rank editing options
- Level up and level down notifications
- Vehicles deleted more seemlessly
- **NEW** Now uses qb-target and polyzone

## Requirements

- [QbCore framework](https://github.com/qbcore-framework)
  - Polyzone
  - qb-target

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

Once there, go next to the NPC and use third eye (left alt) to start the job. You will receive a message about the vehicle you need to steal.

![Job start location](https://i.imgur.com/b4coTdR.png)

Follow the objective, use any lockpick to open the car and hotwire if necessary.<br>
Drive to the destination. Beware, if the car is destroyed, job will **fail**!<br>
Once you arrive at the destination, stop the car inside the objective blip on mini map. Job will finish and you will get paid depending on distance driven and condition of the car.

## Config and translation info

[Head to the wiki page for detailed explanation on each variable](https://github.com/Hiype/hiype-cardelivery/wiki)

## Support

If you wish to support me in any way, you can do so through this link -> [BuyMeACoffee](https://www.buymeacoffee.com/hiype)<br>
