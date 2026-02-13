Your first LS Lua module
------------------------

### Where Lua modules are loaded from

All custom Lua modules (scripts) should be located in `GS\tier3\` folder.

### Lua module structure

*   It must be located in its own folder, for example for `MyLuaModule` it must be: `GS\tier3\MyLuaModule\`.
*   Module name is defined by folder name, in this example it's `MyLuaModule`.
*   Entry point file is `module.lua`, so it in this example it's `GS\tier3\MyLuaModule\module.lua`.
*   Each Lua module in LS has its own environment table. This environment can be accessed externally from other modules by module name. In this example it's `MyLuaModule`.

### Twisted Fate example

With LS we provide very basic open source example of Twisted Fate script. You can find it in `GS\tier3\example-TwistedFate\` to study it.  
It shows some basic and good practices, such as:

*   Not loading the script if you are not playing the right champion by performing hash check
*   Disabling C++ Core champion with `Champions.CppScriptMaster`
*   Loading submodule files with `Environment.LoadModule`
*   Using our [`Callback System`](https://docs.legendsen.se/developers/sdk-documentation/callbacks/callbacksignatures)
*   And so on

Developer Guidelines
====================

Things to follow and things to avoid
====================================

We highly suggest to follow these guidelines when developing Lua scripts for LS.  
Please take your time and go through this article carefully.

Getting Started
---------------

*   LS looks up Lua modules in `GS\tier3\` folder. There is an example Twisted Fate script located in that folder.
*   Lua Manager can be accessed from in-game menu, in `Champion` tab.
*   Module name is the same as folder name in `GS\tier3\{MODULE_NAME}` path.
*   Entry point file must be named `module.lua`.
*   We use luajit-2.1.0 in case if you want luac your raw source to bytecode.
*   For more detailed information read [Getting Started article](https://docs.legendsen.se/developers/getting-started).

Guidelines
----------

### General Lua

*   Avoid using global scope variables (`_G` table).
*   Avoid using `ENV` unique variables such as `MODULE_NAME`. If your script will ever be added to the core - it will have different `ENV`.
*   [Avoid storing refs to C++ objects in Lua variables.](https://docs.legendsen.se/developers/caveats/extreme/cppobjects)

### Hashes

In LS we prefer using hashes where we can instead of string comparisons. This is what the game does, number comparison is faster and more reliable.  
[Read more about hashes here.](https://docs.legendsen.se/developers/caveats/high/hashes)

### Champion Script Requirements

*   Make sure to call [`Champions.CppScriptMaster(false)`](https://docs.legendsen.se/developers/sdk-documentation/sdk-types-and-functions/champions#cppscriptmaster) to unload internal core (C++) champion script. You can see how it's done in example Twisted Fate Lua script.
*   Please always add [`CastSpecialImmobileTarget`](https://docs.legendsen.se/developers/sdk-documentation/sdk-types-and-functions/sdkspell#castspecialimmobiletarget) implementation to your Champion scripts.  
    This is a very basic, yet extremely useful feature. It can use skillshots on target in special conditions, such as recalling in FoW, Master Yi Q landing, Zed R landing or Zhonya.
*   If `DamageLib` is missing damage map for your champion - please add it. You may read more on DamageLib map in sections below.
*   Please carefully follow all `Menu` guidelines.

### Menu

*   Use unique key for your script menu. This is important to avoid script menu conflicts.  
    If you are developing Champion script then make sure to add unique suffix to menu key, i.e.:

    Game.localPlayer.charName .. "_YourName"

*   Make sure to use `Champions.CreateBaseMenu` to create `Extra Settings` menu. This menu is important and generalized. It has common shared keybind for **Spell Farm** feature and several other settings which are generally used by all champion scripts.
*   Avoid using common hotkeys such as keys used by other core scripts like **Orbwalker** or **Evade** \- i.e. don't bind `Z`, `X`, `C`, `V`, `Space`, `K` and so on.  
    Same applies to most common LoL keys, such as `A`, `S`, `D`, `F`, `P` (Shop), etc.  
    However, when it comes to LoL keys - there are some exceptions which we do globally in our scripts. In some cases it is acceptable to override some of these:
    *   You may override `Q`, `W`, `E`, `R` keys if it is passive spell and can add extra functionality to the champion.
    *   It is fine to override `T`, `Y` or some of number keys like `2`, `3`, `4`. `T` and `Y` can be useful for ultimate assistance (semi-auto R), fast combos or other special combos.
    *   Feel free to be creative with these.

### SDK

*   Do not ever use `.displayName` or other localized strings in your logic code, variables, keys, indexes and so on. Instead please use hashes or `.charName`.  
    Localized strings should be used only for visuals, such as texts in Menu for example.
*   [Avoid calling `IssueOrder` directly.](https://docs.legendsen.se/developers/caveats/high/issueorder)
*   Do not throw all `Renderer` functions in `OnImguiDraw` callback. Use only ImGui Renderer functions in `OnImguiDraw`.
*   Please avoid using in your Release code stuff like `DrawCircle3D`, `DrawVectorPoly`, `DrawCross` and other similar `Renderer` functions which are marked for Dev/Debug only use.  
    You may use them if you don't have any other option, but otherwise - please stick to [Release Ready Renderer functions](https://docs.legendsen.se/developers/sdk-documentation/renderer/renderer-api) instead.
*   Avoid using `usePacket` `true` argument in several functions. In general it's better to use `false` by default, unless you know what you are doing and you want specifically to prevent other scripts from processing this call.
*   Do not throw all your logic inside `OnFastTick` handler. Do it only when it's necessary. Instead prefer using `OnTick` and let user decide how fast it runs with `Ticks Delay` setting.  
    Read more about it in [OnTick, OnFastTick and Ticks Delay setting](https://docs.legendsen.se/developers/caveats/high/onfasttick) caveat article

### Caveats

[Caveats](https://docs.legendsen.se/developers/caveats) describe various quirks in our SDK and will help you to avoid some important problems in your code.  
Make sure to check all of them in each severity subcategory.

### Prediction

*   **Important:** In spell data speed property use `math.flt_max` instead of `math.huge`.

### Evade

*   Please do not neglect **Evade API** in your Champion scripts. Good Evade integration is what make a big difference between mediocre and high quality scripts.
*   Evade has built-in `SpellBlock` feature, which simply blocks many spells while evading except those which are in hardcoded whitelist (by default) or using advanced settings in menu (optional).  
    Because of this feature your champion in **Combo Mode** can do silly stuff while evading. That's why it is extremely important to realize when you want to commit to combo or give up on it.
*   General rule is to avoid conflicts with **Evade**. You don't want to start executing important combo while dodging a spell, waste some cooldowns and then Evade will block you from doing the rest.  
    Something like this will look ridiculous, nobody wants something like this to happen to them in-game. There are several things to keep in mind:
    *   You must determine whether you are dodging some dangerous spell already and if yes - then postpone executing important combos.
    *   If you are not dodging anything or dodging low danger level spells (without hard CC) - you may ignore those skillshots on purpose and execute your combo.  
        It's up to you for how long you want to ignore skillshots while executing combo. Don't forget to stop ignoring them once you are done or when some dangerous skillshot is aiming you.
    *   If you are dashing somewhere - please check if it's safe to do so using **Evade API**.  
        If you intend to dash anyway, despite some skillshots in the way or at the end position of the dash - make sure to ignore these skillshots to avoid conflicts, otherwise Evade may dodge these skillshots upon your arrival, rendering all your intentions impossible.

### DamageLib Map

*   **DamageLib** works not only for player's character, but also for enemies and allies.  
    So please keep this in mind while working on it. This means that this code should work even if this hero is an enemy or ally.
*   When adding custom damage functions to damage map please use `Game.spelldataHash` hash method instead of getting spell name from player's spell book entries.
*   Inside damage function body never use hardcoded spell slots! Better use `GetSpellSlot(hash)` to retrieve it first, like in the example below.
*   [You can learn how to extend DamageLib map from this example here.](https://docs.legendsen.se/developers/sdk-documentation/sdk-types-and-functions/damagelib#examples)

C++ objects refs in Lua
=======================

This includes:

*   SDK classes & structs
*   Game entities: `GameObject` derived classes
*   Callback args: `CastArgs`, `CastSpellArgs`, `IssueOrderArgs` etc
*   And so on...

Avoid storing such objects in **Lua variables** which go out of your current usage scope unless you can handle disposal of such objects yourself.  
This means it's fine to store instances of things you create and dispose yourself, such as `Menu` components, `SDKSpell` and things like this. But it's not fine to store game objects from `OnObjectCreate` event or cast args from `OnProcessSpell` event. This can lead to unexpected behavior, errors and even crashes.

Problem
-------

### Explanation

Think of basic example:

> You have a variable called `myTarget` for your main target and during runtime you want it to store certain `AttackableUnit` as target to attack.

So you end up with some code which assigns minions or enemy champions to `myTarget` and rely on this code to check if it's viable target:

    local myTargetCallback.Bind(CallbackType.OnObjectCreate, function(obj)    -- Assign some minion to myTargetend)function AttackMyTarget()    if myTarget and myTarget:IsValid() then        -- Attack myTarget    endend

On paper this should work fine, however, what if you assign a minion which gets killed and game disposes of it, but your Lua script still holds reference or pointer to it?  
`myTarget` won't be nil, but it will point to invalid object. Previously, in LS, calling `myTarget:IsValid()` method would throw exception, possibly corrupt the thread or even cause the crash. Recently this part was improved, we prevent crash in this particular example (`GameObject:IsValid()`), but we don't do it in other cases.

### DelayAction

This problem can also happen in not so obvious scenarios, such as using `DelayAction`. Think of this code:

    Callback.Bind(CallbackType.OnTick, function()    -- body of any event where you find some target, store it in a variable and then pass it to action function argument of DelayAction:    local myTarget = GetSomeTarget()    Common.DelayAction(function()        if myTarget and myTarget:IsValid() then            AttackTarget(myTarget)        end    end, 0)end)

If `myTarget` will be disposed - calling `myTarget:IsValid()` will throw exception. This may happen even with 0 delay in `DelayAction`, which is supposed to delay action only by 1 tick. Sometimes objects can be created and deleted in the same tick.

Solution
--------

*   If it's `GameObject` or its derived class then simply store `.networkId` and retrieve the object later using `ObjectManager.ResolveNetworkId(networkId)`.  
    You may also use `.handle` and `ObjectManager.ResolveHandle(handle)` in some cases, but we suggest using `.networkId` instead and [here's why](https://docs.legendsen.se/developers/caveats/high/networkidorhandle).
*   If it's some other class/structure such as buff info, spell info, Evade skillshot or something like that - just store the data you need specifically, don't store the whole object.

Actions in OnDraw
=================

Problem
-------

Due to security reasons various player actions will be blocked if called during `OnDraw` event.  
This includes casting spells, attacking, issuing movement and so on.  
`OnDraw` and `OnImguiDraw` are meant for visuals, not for logic.

Solution
--------

Use `OnTick` or `OnFastTick` for actual logic and use `OnDraw` with `OnImguiDraw` only for visuals.

Using Hashes
============

Problem
-------

In LS we prefer using hashes where we can instead of string comparisons. This is what the game does too, number comparison is faster and more reliable.

In our case **Hash** is `unsigned int` number built from certain string. There are several hash methods available:

*   [`Game.fnvhash`](https://docs.legendsen.se/developers/caveats/high/hashes#gamefnvhashstr)
*   [`Game.HashStringSDBM`](https://docs.legendsen.se/developers/caveats/high/hashes#gamehashstringsdbmstr)
*   [`Game.spelldataHash`](https://docs.legendsen.se/developers/caveats/high/hashes#gamespelldatahashstr)

Solution
--------

*   Use appropriate hash methods where you can.
*   Avoid calculating hashes in your loop. Instead define them once on script initialization.
*   Avoid hardcoding hashes. For better readability of your code just get hash from string using appropriate hash method.

Examples
--------

### `Game.fnvhash(str)`

Used in buffs, `DrawEffectCircle`, other production ready `Renderer` functions, `SpellData`, etc.

Check for Annie passive buff

    local hash_AnniePassivePrimed = Game.fnvhash("anniepassiveprimed")local buff = Game.localPlayer:FindBuff(hash_AnniePassivePrimed)

### `Game.HashStringSDBM(str)`

Used in `AIBaseClient.hash`, etc.

This condition is true

    local match = Game.HashStringSDBM(Game.localPlayer.charName) == Game.localPlayer.hash

Get Lulu's Faerie

    local function GetFaerie()    local hash_LuluFaerie = Game.HashStringSDBM("lulufaerie")    for _, obj in ObjectManager.allAIBaseClients:pairs() do        if obj:IsValid() and obj.team == caster.team and obj.hash == LuluFaerieHash then            return obj        end    endend

### `Game.spelldataHash(str)`

Used in DamageLib maps.

Get Irelia Q Damage

    local hash_IreliaQ = Game.spelldataHash("IreliaQ")local function GetQDamage(target)    return DamageLib.GetSpellDamage(hash_IreliaQ, Game.localPlayer, target, false, 0, SpellSlot.Q)end

Using IssueOrder
================

Problem
-------

Issuing too many movements may disconnect you from the game server. That's why we implemented internal limit for `IssueOrder` in the core.  
Because of this limit your `IssueOrder` calls may not go through or "fill the bucket" and cause other scripts not to move when they should, therefore causing a conflict between scripts.

Solution
--------

Try to not issuing orders directly, there are ways to avoid it, for example if you need to move your hero then you may rely on `Orbwalker.forcedPosition`.  
This is the correct way of moving your character in `Orbwalker` modes and doesn't cause any conflicts with other scripts.

If you absolutely have to use `IssueOrder` (i.e. for animation cancelling or some other mechanic), then please be sure that you know what you are doing:

*   Have some debug code to count your issue orders per second to see if you are not spamming it.
*   Make sure to always limit it one way or another in your own code, do not rely on the core to do it for you.  
    Ideally you should execute no more than 1 `IssueOrder` per desired action. Never spam it mindlessly to achieve what you want.
*   Some confirmation code to track if your issue order went through and resulted in desired action may be helpful to detect successful actions and prevent spamming.

Network ID vs Handle
====================

Problem
-------

As described in [C++ objects refs in Lua](https://docs.legendsen.se/developers/caveats/extreme/cppobjects) caveat, it is crucial to store `.networkId` or `.handle` instead of actual object references and later retrieve those objects using `ObjectManager.ResolveNetworkId(networkId)` or `ObjectManager.ResolveHandle(handle)`.

However, you may wonder what is better and safer to store. There is a difference between these.  
Always remember, that `.handle` can be reused by the game after reconnect, and `.networkId` is a unique network ID assigned to this object by the server.

Solution
--------

Prefer storing `.networkId` instead of `.handle` for all `GameObject`.

OnTick, OnFastTick and Ticks Delay setting
==========================================

Problem
-------

`OnTick` may be called less often than `OnFastTick` depending on `Ticks Delay` setting. Because of this some developers prefer to throw all their champion logic in `OnFastTick` instead of `OnTick`. This may cause performance issues if not done correctly.

Below you may observe an example from the profiler during the moment when I was holding spacebar using Lua champion script which mostly utilizes `OnFastTick` instead of `OnTick`:

![Example where OnFastTick takes a lot of frame time](https://docs.legendsen.se/assets/images/caveats-profiler-1ee04f5552d1fc69d7dde6b8e99f2ec3.webp)

Solution
--------

Use `OnFastTick` only when it is necessary for your champion and make sure the code inside `OnFastTick` handler is optimized, avoid calling any expensive functions (such as `CreatePath` for example). Ideally you should use it only situationally, for example for very precise and time sensitive logic.

Throw your logic in `OnTick` and let users decide what `Ticks Delay` setting to use.  
If user wants better champion performance and sacrifice some FPS - user can go even with 1ms setting. Normally users should use at least 2-5ms. Right now default is 30ms, but it's a possibly subject to change.