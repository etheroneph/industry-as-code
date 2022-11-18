Dual Universe Industry-As-Code Tool that helps manage your factory. The factory configuration is managed via a Lua configuration file which is imported by each programming board in the factory, each programming board cycles connected industry units through all needed recipes to maintain the desired products any time it is not producing.

![screenshot](/assets/screenshot.png)

# Use-cases

This is primarily intended for small industry - for example:

* you can configure it to maintain all of your ship parts so you don't have to purchase them as they are destroyed
* maintaining fuel
* making an anti-gravity generator or other advanced item without a dedicated factory
* simplifying ore refining allowing you to scale refiners based only on the desired throughput and not number of ores * desired throughput.

This is not intended for all use-cases. Use-cases that demand extreme efficiency will likely want to use something like [a factory generator](https://tvwenger.github.io/du-factory-generator/latest/). It will not be the most efficient for many use-cases and it will require you to be online and next to the programming boards in order to use it (alt recommended), but it will be hands off and easy to configure.

# Features

* Automatically configures products and their dependencies over the entire factory (stop thinking about screws!)
* Rotates industry units through potential recipes to maximize their utilization
* Automatic configures Transfer Units
* A basic read-only UI showing unit status

# Installation

Setup your industry links:

1. Place the programming board
2. Link the programming board to any industry units it should configure (up to 9).
3. (optionally) Link the programming board to a screen to enable the interface.
4. Paste the `industry_as_code.lua` script.
5. Use a relay to start more than one board at a time - use a delay line if more than 8 programming boards.
6. Rename each industry unit to include the "stage" that it is in, for example, "Complex Electronics" (see the section on stages below).
 
Clone the git repository:

```
git clone https://github.com/etheroneph/industry-as-code.git
cd industry-as-code
```

## Build your configuration file

Update `industry_config.lua` with the products that you want the factory to produce, for example, a factory producing nitron fuel, scrap, and warp cells would look like:

```
return {
    { item = "Nitron Fuel", quantity = 10000 },
    { item = "Silicon Scrap", quantity = 1000 },
    { item = "Warp Cell", quantity = 100 },
}
```


Build the configuration file:

```
DUAL_UNIVERSE_PATH="/mnt/c/Games/Dual Universe" make
```

Repeat this step and restart your programming boards any time you need to update the factory configuration.

# Stages

The script loads the desired products from the configuration file, resolves all of their dependencies (and necessary quantities), and then looks at the connected industry units to see which recipes can be fulfilled by them.

The recipes are grouped into logical stages (some units, such as Assembly machines, smelter, honeycomb, have no stages):

- Pure - Pure materials (refiner only).
- Product - Product materials (Refiner, 3D Printer, Chemical Industry, Glass Furnace, implied for Smelter)
- Intermediate - Intermediate parts (Electronics Industry, Metalwork Industry, 3D Printer, Glass Furnace, 
- Complex - Complex parts (Electronics Industry, Metalwork Industry, 3D Printer, Glass Furnace)
- Functional - Functional parts (Electronics Industry, Metalwork Industry, 3D Printer, Glass Furnace)
- Exceptional - Exceptional parts (Electronics Industry)
- Fuel - For making fuel (Kergon, Nitron, Rocket Fuel) (Chemical Industry)
- Honeycomb - Honeycomb materials (Glass Industry, implied for Honeycomb Refiner)

The stages that an industry unit uses are determined by its name. If a stage is in the name it will allow it to produce any of the recipes in that category. Multiple stages can be specified, for example, `exceptional functional electronics 1`. Only the stage is required in the name.

If you need a special factory layout, customize  `industry_unit_map.lua` which contains the mappings of items to which industry units they can be crafted by. It may be necessary to modify this if any of the items or dependencies you need crafted are not already in it or you have special requirements for your industry layout. In most cases, this can be left untouched.

# Transfer Units

The script includes support for transfer units. To determine which items a transfer unit should move, the script enumerates at all connected industry units and the first-level dependencies of the recipes they are configured to craft. The transfer unit will then be configured to cycle through the first-level dependencies in order to make them available.

# Example factory layout

This example shows a basic factory that can process any honeycomb material using a single programming board:

![honeycomb](/assets/honeycomb_factory.png)

This example shows a very simple factory that can manufacture almost any item and can be scaled up fairly easily:

![make-it-all](/assets/make_it_all_factory.png)
