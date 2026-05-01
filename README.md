# VGFarm Addon For DarkRP

VGFarm 1.0

## Features
- Planters
- Seeds
- Growth system
- Watering
- Soiling
- Selling Market
- Hooks API

## Download

[GitHub](https://github.com/CreeperNinja/VGFarm) or [Steam Workshop]()

## Installation
1. Put the addon in `/garrysmod/addons/`
2. Restart server

## Modification
To Modify Addon Go To `lua/autorun/vgfarm_config.lua` (Note: some changes require server restart)

## Modding
For hook implementation for desired behaviours see `Hooks.md`

## DarkRP Setup
Add this to `darkrp_customthings/jobs.lua`:
```lua
TEAM_FARMER = DarkRP.createJob("Farmer", {
    color = Color(50, 200, 50),
    model = {
        "models/player/Group02/male_02.mdl",
        "models/player/Group02/male_04.mdl",
        "models/player/Group02/male_06.mdl",
        "models/player/Group02/male_08.mdl"
    },
    description = [[Buy Grow And Sell Crops To Make A Respectable Income]],
    weapons = {},
    command = "farmer",
    max = 6,
    salary = GAMEMODE.Config.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
})
```
Add this to `darkrp_customthings/categories.lua`:
```lua
DarkRP.createCategory{
    name = "Planter",
    categorises = "entities",
    startExpanded = true,
    color = Color(107, 107, 107),
    sortOrder = 1
}

DarkRP.createCategory{
    name = "Water",
    categorises = "entities",
    startExpanded = true,
    color = Color(0, 70, 107),
    sortOrder = 2
}

DarkRP.createCategory{
    name = "Soil",
    categorises = "entities",
    startExpanded = true,
    color = Color(107, 70, 107),
    sortOrder = 3
}

DarkRP.createCategory{
    name = "Seeds",
    categorises = "entities",
    startExpanded = true,
    color = Color(0, 107, 0),
    sortOrder = 4
}
```

Add this to `darkrp_customthings/entities.lua`:
```lua
DarkRP.createEntity("Large Planter", {
    ent = "planter_large",
    model = "models/planter_large/planter_large.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_large_planter",
    allowed = {TEAM_FARMER},
    category = "Planter",
})

DarkRP.createEntity("Medium Planter", {
    ent = "planter_medium",
    model = "models/planter_medium/planter_medium.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_medium_planter",
    allowed = {TEAM_FARMER},
    category = "Planter",
})

DarkRP.createEntity("Small Planter", {
    ent = "planter_small",
    model = "models/planter_small/planter_small.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_small_planter",
    allowed = {TEAM_FARMER},
    category = "Planter",
})

DarkRP.createEntity("Large Water", {
    ent = "water_large",
    model = "models/water_large/water_large.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_large_water",
    allowed = {TEAM_FARMER},
    category = "Water",
})

DarkRP.createEntity("Medium Water", {
    ent = "water_medium",
    model = "models/water_medium/water_medium.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_medium_water",
    allowed = {TEAM_FARMER},
    category = "Water",
})

DarkRP.createEntity("Small Water", {
    ent = "water_small",
    model = "models/water_small/water_small.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_small_water",
    allowed = {TEAM_FARMER},
    category = "Water",
})

DarkRP.createEntity("Dirt", {
    ent = "base_dirt",
    model = "models/sack/sack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_dirt",
    allowed = {TEAM_FARMER},
    category = "Soil",
})

DarkRP.createEntity("Carrot Seeds", {
    ent = "seeds_carrot",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_carrot",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Potato Seeds", {
    ent = "seeds_potato",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_potato",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Onion Seeds", {
    ent = "seeds_onion",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_onion",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Tomato Seeds", {
    ent = "seeds_tomato",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_tomato",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Cucumber Seeds", {
    ent = "seeds_cucumber",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_cucumber",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Lettuce Seeds", {
    ent = "seeds_lettuce",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_lettuce",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Strawberry Seeds", {
    ent = "seeds_strawberry",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_strawberry",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Eggplant Seeds", {
    ent = "seeds_eggplant",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_eggplant",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Pumpkin Seeds", {
    ent = "seeds_pumpkin",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_pumpkin",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

DarkRP.createEntity("Watermelon Seeds", {
    ent = "seeds_watermelon",
    model = "models/seedpack/seedpack.mdl",
    price = 5,
    max = 6,
    cmd = "vgfarm_buy_watermelon",
    allowed = {TEAM_FARMER},
    category = "Seeds",
})

```