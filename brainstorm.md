

# **Personalization. System**

User will get a questionnaire about what they really like gameplay style in terms of character type . Perks , special events , goals will all use this input when crafting subscription tier specials 

# **Goals system**

Monthly changing quests, daily bonuses for logging in , and something really special personalized for the subscriber 

# **Banking**

A user can create a bank account for a specific character instance where they can save their currency so it doesn’t get taken if they die 

This is another feature off the traders hub

The above comes with premium

As a part of subscription we can offer quantum banking addon that allows you to transfer currency for one character instances bank to another’s

# **Global stats as the operator of the app**

Internally I want a dashboard to gives me user behavior for the following

Popularity of character types, items and minions , when users are the most active in which regions. Also I want stats on who is posting their trading cards on social media platforms. 

# **Log feature for users**

A feature that categorizes , organizes, makes it searchable any events that I feel should be logged for a users awareness. It could be a new perk, upcoming special events , marketing , etc… essentially my message area to the users 

This layer is for all tiers 

However I have an ide for. Subscription feature. “Advisor” which reviews what you could have done better in the last wave your character instance was in. It could give you a weekly summary of how you played each character instance and suggestions on what you did well and what could have gone better. This is probably an extremely advanced feature for later on but if we should make architectural changes now for it I wanted you to know. I assume we will need to store all choices they made in features in the hub and a well as monitor how they did on the wave and what they should focus on in the trader’s hall to improve for example the user has been taking the glass canon approach and while they do big number damage the die within x seconds if hit. Invest in dodge or armor or looks for ways to mitigate through healing , consumables and life steal. Something like that we should be able to build some straight forward heuristics I would imagine 

# **Perks system**

This is going to be a nice personalization feature

I want a way to make the user experience unique to a user by being able to alter game play at this perks layer. I want the flexibility to do something like give a specific user a perk where every character they make during a certain period based upon some criteria gets an addition 10 hit points for example. Perks can be permanent or have specific duration. I should also be able to issue a deletion trigger to all clients if needed as well.

Our traders hall should have a feature where you can enter a code that may activate a perk that we use for marketing. But I plan to have some schedule of regular perks to change up gameplay. Perks once activated can not be removed by any means  by the user unless they are configured to have duration and the perks self delete. 

Premium will be tbd on what perks when

But subscription will get 1 perk a week that will always have a week duration so every week gameplay will change in subtle ways. It was always be a fun positive perk for gameplay

Perks will be toggle able though you can opt out if you don’t want that uncertainty and you will not be presented the perk at all.

Think of this as a scheduler for mods I the operator of app have the ability to add and turn on and off when I want to some or all of our users based upon criteria I set when… eg a perk to users that are in Latin America for the day of the dead. I’ll probably need to build some builder app  or wizard to operate these effectively.

What key is I don’t want to have to deploy a new release to users I should be able to inject  a new perk event  from the backend to the mobile clients with and not force a new release on people. As well as remove it or deactivate when I wish to as well.

Ordering active perks could be very non deterministic so let’s add guard rails. Perks will be applied fifo but before we apply perk we add perks in one of two ways we can either add the item to to back so that it will get applied last or it will get added to the front and will be the first perk applied

Perks will have to have hooks in character instance creation , leveling, the store / black market / atomic vending machine , when the character instance is damaged in the wasteland , when a character instance damages a monster , when a character heals or steals life , when they move on the wasteland , when they die I think should cover most of the use cases on where we can inject perk behavior  

This will use the personalization system to make these perks tailored to the user

# **Trading card for character instances**

A feature that generates a trading card one of you character instances, all their stats , an image of that character with all their items and minions. The report card could have multiple presentations. A roster feature from the traders hub that you can tab through to see all your characters or a catchy image suitable for posting on social media. The social media aspect could be part of marketing and we give the user options for referrals in the post , codes for new users to get perks , link to the game, etc… essentially an easy grass roots way for fans to member for us on whatever platform they use.

# **Special events**

Both for premium and some additional unique events for subscription tier

The ability to create temporary and unique environmental changes in what we will call “the wasteland”. The wasteland is where the waves are fought.

Some ideas are 

Special unique buffs and debuffs that appear randomly on the wasteland  for the wave, items that drop only for these events, specially themed monsters  with special powers, changes in the environment such as acid pools, lava, “slow” fields where your speed is greatly reduced. Teleport traps to move you to a different part of the the wasteland . 

# **Traders hub**

After a wave completes the character instance should be taken to a traders hall that have multiple options based upon free , premium and subscription status 

# **Quantum Storage**

Gives another option to the traders hub where you can move an item or minion from your character instance to storage that all your character instances can access it and take it out of the stash

I think a reasonable limitation here is you can move item 1x from one character instance to another and then it can’t go through quantum storage again

# **Minion system for a later phase**

Bots, pets, and contractors that will play by your side with different benefits and drawbacks 

Minions can level and increased their power of whatever effects they provide but they can’t use items. They can be damaged and can die.

Each type of minion will be vulnerable to an specific type of damage mutant / melee / ranged  

You can only use 1 minion at a given time   
Minions will be stored in barracks feature accessible from the traders hub  
Minions are bound to a specific character instance not globally to all of the users characters 

# **Research an appropriate subscription price**

# **Assertion you can only enable the subscription in the premium app**

# **Character types**

[https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters)

# **Atomic vending machine**

This feature will offer 1x week a choice of 3 items that are uniquely tailored to your character of choice for sale. This can also include a unique minion

And will appear at the traders hub after a wave completes 

# **Black market**

 A store that has a smaller set of offerings but are at a higher tier and cost   
 

It will located at the traders hub 

It will also very occasionally sell a curse removal scroll at a very high price 

# **We need items and a store**

Random items that alter game play   
Can also contain reagents for workshop   
Reroll functionality for a fee of options  
You can also sell items in the store

Items can randomly drop from mobs the higher the tier of mob the better quality drop. The character stat can impact drop chances/

Items can be damaged and destroyed. They can not be repaired other than slowly in the Mrfixit appliance as part of the subscription tier.

Items take damage on the characters death

Items can drop and be randomly cursed. A cursed item can’t be sold so if it has negative effects the user is stuck with them 

Here is Brotato item system 

[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)

Items are bound to the character instance they were found not globally to the user 

This will be accessible from the traders hub where the character instances will go to after a wave 

# **Stat system that impacts gameplay**

I like the one that Brotato uses

The stat system should introduce character leveling which will have bonuses based upon the character type .  Collecting currency  and killing mobs are used ways to level but would like other suggestions. Both things should have a point equivalent towards their next level. 

Here is Brotato s [https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)

Id change elemental damage to mutant power which is a premium tier feature for some of our premium character types  
Mutant power will impact items that grant a passive mutant effect to the character or if the character type comes with a mutant effect  
Not all character types will have the mutant power stat

Death will randomly drop a stat by 1 point and death reset the amount they need to get to their next level.  
The traders hub will have an advancement hall option where the character instances will be offered a random set of choices to select from for each level up they have accrued. The choices should be based upon the character type. Along with whatever bonuses that character type gets per level if any

Death will also 0 out any currency you have on you 

# **Random monsters that drop recipes or special reagents required to craft special temporary buffs or weapons**

# **Cultivation pod & Scavenger mode & mrfixit & minion fabricator**

Cultivation pod, while they are not playing they get some sort of benefit accumulation maybe something towards their stats. Like a upgrade station where you can pick a stat and slowly increase it when you are offline you can pick 1 stat to do at a time

We’d have to have some way to make sure this doesn’t cause some crazy edge cases. 

An option to accumulate game currency with a scavenger mode. The user can only be in  the upgrade chamber or scavenging at one time not both.

We will have the MrFixit that will allow a user to repair 1 item very slowly. While it is in the mrfixit it can’t be used by the user and removed from their inventory.

Minion Lab \- will store a pattern of  the minon for a very high price the higher the tier of the minion the higher the price. You can then create a clone of that minion for a very high price. Each time you clone the price is higher and the clone pattern is a random % less powerful than the last time pattern was used. When clone pattern viability (a stat which starts at 100 and loses that random amount of points each time a clone is made) reaches 0 the pattern is destroyed and removed.

# **Feature request submission**

Let’s add some sort of system to really engage the user. I want to know their ideas for future features 

I think what I’d like to do with this is let ideas accumulate , let people vote on the ideas every two weeks I’ll hold  tip goal for the the feature that got the most votes people will tip me to prioritize that request and if I reach the tip goal say $1,000 I work on that feature first. 

This would be a feature I’d turn on fret we show some the appropriate amount of success that would indicate this feature would be viable 

We should also use this for 1x month perk request at the premium tier. Let the users decide what the first perk of a next month it will be  a full week. If people do not participate then there is no guarantee what the first perk of the month will be. 

# **We need a achievement system\!**

# **Controller support**

Let’s offer controller support as a premium feature if that is possible 

Also do some research about supporting backbone 

# **current thoughts**

make sure to ask gemini if there is a better tool than replace  
make sure stable is pushed to remote

For tomorrow ,

1\. Get GitHub clinindtalled and cauldron doing that  
2\. Discuss local storage vs remote  db  
3\. Go over code review  
4\. discuss  systems that alter gameplay remotely   
5\. Test coverage get it in and hook it into GitHub

1\. yes and remember this is a windows laptop and I do dev in a WSL. well right now there is only one project in my projects directory it has one .claude directory. my idea this project and any other projects i start on will live here so one main location to look for everything. 2\. I don't have it mounted I'll take whatever you recommend as best here. 3\. I was like 4am every night when I'm guaranteed not to be doing any work :) for the retention policy i'll take your recommendations. 4\. ubuntu, i'm totally comfortable adding the tools we need just provide good instructions for it. 5\. I would be ok with using git but are there any concerns in terms of security, intellectual property or anything like that since our session files really are the heart of everything. I have no background with rclone so please make a case for it if you think it is worth going for. I think under your better approach options 1\. maybe the best bet but please review what i am saying above. also remember i'm a solo indie developer with not a lot of money :) oh the .claude directories have all of our work in it. I heavily use continuity session files as part of my workflow. It's the way i tune a new chat with all of our long running context quickly.

# **Context**

I brainstormed some ideas I want your take on and I also want to confirm some things for the current roadmap.First off, I want to confirm that you are incorporating concepts that roguelites like Brotato use. If you haven’t already please review, pull the data about the game from the wiki here: [https://brotato.wiki.spellsandguns.com/Brotato\_Wiki](https://brotato.wiki.spellsandguns.com/Brotato_Wiki). In particular please incorporate elements from the following areas:

[https://brotato.wiki.spellsandguns.com/Weapons](https://brotato.wiki.spellsandguns.com/Weapons)  
[https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters)  
[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)  
[https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)  
[https://brotato.wiki.spellsandguns.com/Enemies](https://brotato.wiki.spellsandguns.com/Enemies)  
[https://brotato.wiki.spellsandguns.com/Shop](https://brotato.wiki.spellsandguns.com/Shop)  
[https://brotato.wiki.spellsandguns.com/Progress](https://brotato.wiki.spellsandguns.com/Progress)  
[https://brotato.wiki.spellsandguns.com/Upgrades](https://brotato.wiki.spellsandguns.com/Upgrades)  
[https://brotato.wiki.spellsandguns.com/Danger\_Levels](https://brotato.wiki.spellsandguns.com/Danger_Levels)  
[https://brotato.wiki.spellsandguns.com/Endless\_Mode](https://brotato.wiki.spellsandguns.com/Endless_Mode)  
https://brotato.wiki.spellsandguns.com/Miscellaneous

After you have reviewed the above please then start reviewing my ideas below. I would like your thoughts, suggestions, and recommendations. Please note besides trying to make the app sticky for players with features that enhance gameplay I am also trying to differentiate the now 3 tiers for this game. Free, Premium, and Subscription. Please pay attention to how I’m categorizing the following systems and features and let me know if how I’m dividing things makes sense, is optimal from a monetization standpoint..  
Also going forward the “wave” part of this application where a character instance is fighting should be called, “The Wasteland”.   
I will be referring to other ideas and features in this doc that I may define later in the doc so please read the entire doc first and then begin your review and collaboration.

I apologize if i’m going over things you already had in mind for future phases but given the number of systems i think could be useful to add I wanted to lay things out and get your review, recommendations, and collaboration. Please don’t write any code or execute anything just yet. I want to keep an open brainstorm with you before we consider any sort of  implementation 

# **Personalization  System** 

1. This is specifically a subscription tier feature  
2. There should be an option to enter this system from the Scrapyard.

A user will have  the option to fill out a  questionnaire about what they really like gameplay style in terms of character type . perks , special events , and goals. These preferences will be used as a data point when crafting subscription tier special features.

There isn’t a 1:1 to relationship between a user and this questionnaire. Instead this personalization system is a 1:1 with each of the user’s existing character type instances. 

The user will have the option to designate one of their  character type instances as the primary personalization selection. Special features for subscription tier will use that primary selection as a data point for the feature.

# **Goals system (internal system that I will operate)**

1. For all tiers

Monthly changing quests, daily bonuses for logging in , and something  additional for the subscription tier. 

I think I will need some sort of tool for managing goals.

Goals will be available at every service tier but here some ideas for tier constraint

Free tier: less frequency, random goals are issued. Their rewards are of the least value. Daily logging in will be the primary goal for free tier, holiday related goals

Premium tier: daily and weekly goals, login goals as well as everything Free provides

Subscription: Everything the other tiers provide but also a beginning and end of the month goal that uses the personalization system 

# **Banking system**

1. Is only available for premium and subscription tier  
2. Should be accessible from Scrapyard

A user can create a bank account for a specific character type instance where they can save their currency so it doesn’t get wiped out on death (we havent instituted wipe out scrap on death yet)

 Subscription tier will have an additional feature, “quantum banking” which will  allow you to transfer currency for one character instances bank to another’s

# **Global stats (internal system I will operate)**

Internally I want a dashboard to gives me user behavior for the following

Popularity of character types, items and minions , when users are the most active in which regions. Also I want stats on who is posting their trading cards (to be further defined later in this doc) on social media platforms. 

# **Log feature of  users (internal system I will operate)**

A feature that categorizes , organizes, makes it searchable any events that I feel should be logged for a users awareness. It could be a new perk, upcoming special events , marketing , etc… essentially my message area to the users 

This layer is for all tiers 

However I have an idea for a subscription feature for users. Let’s call it the. “Advisor” which reviews what you could have done better in the last wave your character instance was in. It could also give you a weekly summary of how you played each character instance and suggestions on what you did well and what could have gone better. This is probably an extremely advanced feature for later on but if we should make architectural changes now for it I wanted you to know. I assume we will need to store all choices they made in features in the hub and a well as monitor how they did on the wave and what they should focus on in the Scrapyard  to improve for example the user has been taking the glass canon approach and while they do big number damage the die within x seconds if hit. Invest in dodge or armor or look for ways to mitigate through healing , consumables and life steal. Something like that we should be able to build some straight forward heuristics I would imagine 

# **Perks system**

This is going to be a nice personalization feature for premium and subscription

I want a way to make the user experience unique to a user by being able to alter game play at this perks layer. I want the flexibility to do something like give a specific user a perk where every character they make during a certain period based upon some criteria gets an additional 10 hit points for example. Perks can be permanent or have specific duration. I should also be able to issue a deletion trigger for a perk as well  to all clients if needed as well.

Scrapyard should have a feature where you can enter a code that may activate a perk that we use for marketing.I plan to have some schedule of regular perks to change up gameplay. Perks once activated can not be removed by any means  by the user unless they are configured to have duration and the perks self delete. 

Premium will be tbd on what perks when

But the subscription tier will get 1 perk a week that will always have a week duration so every week gameplay will change in subtle ways. It was always be a fun positive perk for gameplay

Perks will be all or nothing setting. You can opt out if you don’t want that uncertainty and you will not be presented with the perk at all.

Think of this as a scheduler for temporary mods I issue to the entire playerbase. The internal operator of this app  should have the ability to add and turn on and off when I want to some or all of our users based upon criteria I set when… eg a perk to users that are in Latin America for the day of the dead. I’ll probably need to build some builder app  or wizard to operate these effectively.

What key is I don’t want to have to deploy a new release to users I should be able to inject  a new perk event  from the backend to the mobile clients with and not force a new release on people. As well as remove it or deactivate when I wish to as well.

Ordering active perks could be very non deterministic so let’s add guard rails. Perks will be applied fifo but before we apply a perk we add perks in one of two ways we can either add the perk  to back so that it will get applied last or it will get added to the front and will be the first perk applied

Perks will have to have hooks in character instance creation , leveling, the store / black market / atomic vending machine , when the character instance is damaged in the wasteland , when a character instance damages a monster , when a character heals or steals life , when they move on the wasteland , when they die I think should cover most of the use cases on where we can inject perk behavior but feel free to make other suggestions.

This will use the personalization system to make these perks tailored to the user

# **Trading card for character instances**

1. This will be available every tier  
2. An idea i had was maybe there is a path for Free tier users to earn Premium by bringing in enough referrals?  
3. In general referrals should award users in game bonuses.  
   

A feature that generates a trading card of character type instances, all their stats , an image of that character with all their items and minions. The card could have multiple presentations. A roster feature from the Scrapyard that you can tab through to see all your characters or a catchy image suitable for posting on social media. The social media aspect could be part of marketing and we give the user options for referrals in the post , codes for new users to get perks , link to the game, etc… essentially an easy grass roots way for fans to member for us on whatever platform they use.

# **Special events system**

1. For Premium and Sub Tiers

The ability to create temporary and unique environmental changes in the wasteland.

Some ideas are 

Special unique buffs and debuffs that appear randomly on the wasteland  for the wave, items that drop only for these events, specially themed monsters  with special powers, changes in the environment such as acid pools, lava, “slow” fields where your speed is greatly reduced. Teleport traps to move you to a different part of the wasteland . 

# **Quantum Storage**

1. Subscription tier only  
   

Gives another option to the Scrapyard where you can move an item or minion from your character instance to storage that all your character instances can access it and take it out of the stash

I think a reasonable limitation here is you can move item 1x from one character instance to another and then it can’t go through quantum storage again

# **Minion system**

1. Premium and Subscription only   
   

Bots, pets, and contractors that will play by your side with different benefits and drawbacks 

Minions can level and increase their power of whatever effects they provide but they can’t use items. They can be damaged and can die. I think they should have a different leveling mechanism than character instances. Maybe we introduce rare food or items that trigger leveling

Each type of minion will be vulnerable to a specific type of damage mutant / melee / ranged  

You can only use 1 minion at a given time   
Minions will be stored in barracks feature accessible from Scrapyard.  
Minions are bound to a specific character instance not globally to all of the users characters 

# **Barracks system**

This is the original ideation for barracks please review against our current implementation and let me know what you think

1. Premium and subscription tier only  
2. Premium gets 3 minions slots in total for all character type instances  
3. Subscription gets 1 additional minon slot for each character instance  
4. So 3 additional minions for premium, 1 alternate minon for each character instance in subscription mode.

Barracks are accessible from Scrapyard

# **Character types and the user instances of them**

1. [https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters) 

We can use the above url as reference. 

I’d like some brainstorming on how we can differentiate between free, premium, sub with the number of instances allowed.

# **Atomic vending machine system**

1, subscription tier only.

This feature will offer 1x week a choice of 3 items that are uniquely tailored to your character of choice for sale. This can also include a unique minion

Accessible from Scrapyard

# **Black market system**

1. Premium and subscription tier 

 A store that has a smaller set of offerings but are at a higher tier of quality  and have a more inflated cost  
   
Accessible from Scrapyard

It will also very occasionally sell a curse removal scroll at a very high price   
\*\*\* we havent’d discussed curses in a while but some item drops should have negative consequences if the item is cursed the user can not bank or sell the item. They are stuck with it unless they can remove the curse on it. 

# **Items & Store system**

Random items that alter game play get stocked in the store each time a user completes a wave

Can also contain reagents for the workshop   
Reroll of the items functionality for a fee   
You can also sell items in the store

Items can randomly drop from mobs. the higher the tier of mob the better quality drop. The character stat can impact drop chances (LUCK)

Items can be damaged and destroyed. They can not be repaired other than slowly in the Mr fixit appliance as part of the subscription tier idle game feature.

Items take damage on the characters death. They durability and can be destroyed when it reaches 0\.

Items can drop and be randomly cursed. A cursed item can’t be sold so if it has negative effects the character instance is stuck with them . The black market willl every so often offer a curse removal scroll that can remove the cursed attributed from the item.

Here is Brotato item system 

[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)

Items are bound to the character instance they were found in and are not globally accessible  to the user 

This will also be accessible from the Scrapyard

# **Stat system that impacts gameplay**

I like the one that Brotato uses

The stat system should introduce character leveling which will have bonuses based upon the character type .  Collecting currency  and killing mobs are used ways to level but would like other suggestions. Both things should have a point equivalent towards their next level. 

Here is Brotato s [https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)

Id change elemental damage to mutant power which is a premium tier feature for some of our premium character types  
Mutant power will impact items that grant a passive mutant effect to the character or if the character type comes with a mutant effect  
Not all character types will have the mutant power stat

Death will randomly drop a stat by 1 point and death reset the amount they need to get to their next level.  
Scrapyard will have an advancement hall featrure where the character instances will be offered a random set of choices to select from for each level up they have accrued. The choices should be based upon the character type. Along with whatever bonuses that character type gets per level if any and of course perks can impact leveling.

Death will also 0 out any currency you have on you 

Please note how I want to run leveling deviates from what Brotato does.

# **Random monsters that drop recipes usable in the workshop or special reagents required to craft special temporary buffs or enhance weapons**

# **Cultivation pod & Murder Hobo mode & Mr FixIT & minion fabricator system (IDLE GAME FOR SUBSCRIBERS)**

1. Subscription only   
   

Cultivation pod, while they are not playing they get some sort of benefit accumulation maybe something towards their stats. Where a single  character instance can  pick a stat and slowly increase it when you are offline the user can only pick 1 stat for 1 specific character instance.

We’d have to have some way to make sure this doesn’t cause some crazy edge cases and not break the game.

Murder Hobo mode. An option to accumulate game currency while offline. The single character instance can only be in  the cultivation chamber or murder hoboing at any given time not both. 

 MrF ixit that will allow a character instance to repair 1 item very slowly. While it is in the mrfixit it can’t be used by the character instance and is removed from their inventory.

Minon Fabricator will store a pattern of the for a very high price  the higher the tier of the minion the higher the price. You can then create a clone of that minion for a very high price. Each time you clone the price is higher and the clone pattern is a random % less powerful than the last time pattern was used. When clone pattern viability (a stat which starts at 100 and loses that random amount of points each time a clone is made) reaches 0 the pattern is destroyed and removed.

# **Feature request system**

Let’s add some sort of system to really engage the user. I want to know their ideas for future features 

I think what I’d like to do with this is let ideas accumulate , then let people vote on the ideas every two weeks I’ll hold  tip goal for the the feature that got the most votes people will tip me money to prioritize that request and if I reach the tip goal say $1,000 I work on that feature first. 

I think this system will me  much much later one we start using BUT if it impacts current architectural decisions i wanted to discuss.

I may want to A/B test this system a bit and see if it is really viable.

We should also use this for a 1x month perk request at the premium tier. Let the users decide what the first perk of a next month it will be  a full week. If people do not participate then there is no guarantee what the first perk of the month will be. 

# **We need a achievement system\!**

	Some standard that that games of this type would do.

# **Controller support**

Let’s offer external controller support. Could we gate this as a premium feature?

Also do some research about supporting backbone hardware?

**Traders hub**

After a wave completes the character instance should be taken to a traders hall that have multiple options based upon free , premium and subscription status

**Quantum Storage**

Gives another option to the traders hub where you can move an item or minion from your character instance to storage that all your character instances can access it and take it out of the stash

**Minion system for a later phase**

Bots, pets, and contractors that will play by your side with different benefits and drawbacks

Minions can level and increased their power of whatever effects they provide but they can’t use items. They can be damaged and can die.

Each type of minion will be vulnerable to an specific type of damage mutant / melee / ranged

You can only use 1 minion at a given time  
Minions will be stored in barracks feature accessible from the traders hub  
Minions are bound to a specific character instance not globally to all of the users characters

**Research an appropriate subscription price**

**Assertion you can only enable the subscription in the premium app**

**Character types**

[https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters)

**Atomic vending machine**

This feature will offer 1x week a choice of 3 items that are uniquely tailored to your character of choice for sale. This can also include a unique minion

And will appear at the traders hub after a wave completes

**Black market**

 A store that has a smaller set of offerings but are at a higher tier and cost  
 

It will located at the traders hub

It will also very occasionally sell a curse removal scroll at a very high price

**We need items and a store**

Random items that alter game play  
Can also contain reagents for workshop  
Reroll functionality for a fee of options  
You can also sell items in the store

Items can randomly drop from mobs the higher the tier of mob the better quality drop. The character stat can impact drop chances/

Items can be damaged and destroyed. They can not be repaired other than slowly in the Mrfixit appliance as part of the subscription tier.

Items take damage on the characters death

Items can drop and be randomly cursed. A cursed item can’t be sold so if it has negative effects the user is stuck with them

Here is Brotato item system

[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)

Items are bound to the character instance they were found not globally to the user

This will be accessible from the traders hub where the character instances will go to after a wave

**Stat system that impacts gameplay**

I like the one that Brotato uses

The stat system should introduce character leveling which will have bonuses based upon the character type . Collecting currency and killing mobs are used ways to level but would like other suggestions. Both things should have a point equivalent towards their next level.

Here is Brotato s [https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)

Id change elemental damage to mutant power which is a premium tier feature for some of our premium character types  
Mutant power will impact items that grant a passive mutant effect to the character or if the character type comes with a mutant effect  
Not all character types will have the mutant power stat

Death will randomly drop a stat by 1 point and death reset the amount they need to get to their next level.  
The traders hub will have an advancement hall option where the character instances will be offered a random set of choices to select from for each level up they have accrued. The choices should be based upon the character type. Along with whatever bonuses that character type gets per level if any

**Random monsters that drop recipes or special reagents required to craft special temporary buffs or weapons**

**Upgrade chamber & Scavenger mode**

Upgrade chamber , while they are not playing they get some sort of benefit accumulation maybe something towards their stats. Like a upgrade station where you can pick a stat and slowly increase it when you are offline you can pick 1 stat to do at a time

We’d have to have some way to make sure this doesn’t cause some crazy edge cases.

An option to accumulate game currency with a scavenger mode. The user can only be in the upgrade chamber or scavenging at one time not both.

We will have the MrFixit that will allow a user to repair 1 item very slowly. While it is in the mrfixit it can’t be used by the user.

Mrcloneit will store a pattern of the for a very high price the higher the tier of the minion the higher the price. You can then create a clone of that minion for a very high price. Each time you clone the price is higher and the clone pattern is a random % less powerful than the last time pattern was used. When clone pattern viability (a stat which starts at 100 and loses that random amount of points each time a clone is made) reaches 0 the pattern is destroyed and removed.

**Feature request submission**

Let’s add some sort of system to really engage the user. I want to know their ideas for future features

**We need a achievement system\!**

**Controller support**

Let’s offer controller support as a premium feature if that is possible

Also do some research about supporting backbone

**Traders hub**

After a wave completes the character instance should be taken to a traders hall that have multiple options based upon free , premium and subscription status

**Quantum Storage**

Gives another option to the traders hub where you can move an item or minion from your character instance to storage that all your character instances can access it and take it out of the stash

**Minion system for a later phase**

Bots, pets, and contractors that will play by your side with different benefits and drawbacks

Minions can level and increased their power of whatever effects they provide but they can’t use items. They can be damaged and can die.

Each type of minion will be vulnerable to an specific type of damage mutant / melee / ranged

You can only use 1 minion at a given time  
Minions will be stored in barracks feature accessible from the traders hub  
Minions are bound to a specific character instance not globally to all of the users characters

**Research an appropriate subscription price**

**Assertion you can only enable the subscription in the premium app**

**Character types**

[https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters)

**Atomic vending machine**

This feature will offer 1x week a choice of 3 items that are uniquely tailored to your character of choice for sale. This can also include a unique minion

And will appear at the traders hub after a wave completes

**Black market**

 A store that has a smaller set of offerings but are at a higher tier and cost  
 

It will located at the traders hub

It will also very occasionally sell a curse removal scroll at a very high price

**We need items and a store**

Random items that alter game play  
Can also contain reagents for workshop  
Reroll functionality for a fee of options  
You can also sell items in the store

Items can randomly drop from mobs the higher the tier of mob the better quality drop. The character stat can impact drop chances/

Items can be damaged and destroyed. They can not be repaired other than slowly in the Mrfixit appliance as part of the subscription tier.

Items take damage on the characters death

Items can drop and be randomly cursed. A cursed item can’t be sold so if it has negative effects the user is stuck with them

Here is Brotato item system

[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)

Items are bound to the character instance they were found not globally to the user

This will be accessible from the traders hub where the character instances will go to after a wave

**Stat system that impacts gameplay**

I like the one that Brotato uses

The stat system should introduce character leveling which will have bonuses based upon the character type . Collecting currency and killing mobs are used ways to level but would like other suggestions. Both things should have a point equivalent towards their next level.

Here is Brotato s [https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)

Id change elemental damage to mutant power which is a premium tier feature for some of our premium character types  
Mutant power will impact items that grant a passive mutant effect to the character or if the character type comes with a mutant effect  
Not all character types will have the mutant power stat

Death will randomly drop a stat by 1 point and death reset the amount they need to get to their next level.  
The traders hub will have an advancement hall option where the character instances will be offered a random set of choices to select from for each level up they have accrued. The choices should be based upon the character type. Along with whatever bonuses that character type gets per level if any

**Random monsters that drop recipes or special reagents required to craft special temporary buffs or weapons**

**Upgrade chamber & Scavenger mode**

Upgrade chamber , while they are not playing they get some sort of benefit accumulation maybe something towards their stats. Like a upgrade station where you can pick a stat and slowly increase it when you are offline you can pick 1 stat to do at a time

We’d have to have some way to make sure this doesn’t cause some crazy edge cases.

An option to accumulate game currency with a scavenger mode. The user can only be in the upgrade chamber or scavenging at one time not both.

We will have the MrFixit that will allow a user to repair 1 item very slowly. While it is in the mrfixit it can’t be used by the user.

Mrcloneit will store a pattern of the for a very high price the higher the tier of the minion the higher the price. You can then create a clone of that minion for a very high price. Each time you clone the price is higher and the clone pattern is a random % less powerful than the last time pattern was used. When clone pattern viability (a stat which starts at 100 and loses that random amount of points each time a clone is made) reaches 0 the pattern is destroyed and removed.

**Feature request submission**

Let’s add some sort of system to really engage the user. I want to know their ideas for future features

**We need a achievement system\!**

**Controller support**

Let’s offer controller support as a premium feature if that is possible

Also do some research about supporting backbone

# **Context**

I brainstormed some ideas I want your take on and I also want to confirm some things for the current roadmap.First off, I want to confirm that you are incorporating concepts that roguelites like Brotato use. If you haven’t already please review, pull the data about the game from the wiki here: [https://brotato.wiki.spellsandguns.com/Brotato\_Wiki](https://brotato.wiki.spellsandguns.com/Brotato_Wiki). In particular please incorporate elements from the following areas:

[https://brotato.wiki.spellsandguns.com/Weapons](https://brotato.wiki.spellsandguns.com/Weapons)  
[https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters)  
[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)  
[https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)  
[https://brotato.wiki.spellsandguns.com/Enemies](https://brotato.wiki.spellsandguns.com/Enemies)  
[https://brotato.wiki.spellsandguns.com/Shop](https://brotato.wiki.spellsandguns.com/Shop)  
[https://brotato.wiki.spellsandguns.com/Progress](https://brotato.wiki.spellsandguns.com/Progress)  
[https://brotato.wiki.spellsandguns.com/Upgrades](https://brotato.wiki.spellsandguns.com/Upgrades)  
[https://brotato.wiki.spellsandguns.com/Danger\_Levels](https://brotato.wiki.spellsandguns.com/Danger_Levels)  
[https://brotato.wiki.spellsandguns.com/Endless\_Mode](https://brotato.wiki.spellsandguns.com/Endless_Mode)  
https://brotato.wiki.spellsandguns.com/Miscellaneous

After you have reviewed the above please then start reviewing my ideas below. I would like your thoughts, suggestions, and recommendations. Please note besides trying to make the app sticky for players with features that enhance gameplay I am also trying to differentiate the now 3 tiers for this game. Free, Premium, and Subscription. Please pay attention to how I’m categorizing the following systems and features and let me know if how I’m dividing things makes sense, is optimal from a monetization standpoint..  
Also going forward the “wave” part of this application where a character instance is fighting should be called, “The Wasteland”.   
I will be referring to other ideas and features in this doc that I may define later in the doc so please read the entire doc first and then begin your review and collaboration.

I apologize if i’m going over things you already had in mind for future phases but given the number of systems i think could be useful to add I wanted to lay things out and get your review, recommendations, and collaboration. Please don’t write any code or execute anything just yet. I want to keep an open brainstorm with you before we consider any sort of  implementation 

# **Traders hub**

1. I’m not set on this name, I’m terrible with coming up with names feel free to offer up alternatives once you understand what this feature is meant to be.  
2. Trader’s hub exists in all 3 tiers of service  
3. Until we come up with our ideal name for this feature I’ll refer to it within this document as TH  
4. TH should be considered the “Home” , “Spoke”, “Base” of this game. A user should always start the game in the TH.  
   

After a wave completes the character instance should be taken to a trader’s  hub where they will have options based on service tier before they go into the next wave.

# **Personalization  System** 

1. This is specifically a subscription tier feature  
2. There should be an option to enter this system from the Trader’s Hub.

A user will have  the option to fill out a  questionnaire about what they really like gameplay style in terms of character type . perks , special events , and goals. These preferences will be used for this input when crafting subscription tier special features.

There isn’t a 1:1 to relationship between a user and this questionnaire. Instead this personalization system is a 1:1 with each of the user’s existing character type instances. 

The user will have the option to designate one of their  character type instances as the primary personalization selection. Special features for subscription tier will use that primary selection as a data point for the feature.

# **Goals system (internal system that I will operate)**

Monthly changing quests, daily bonuses for logging in , and something  additional for the subscription tier. 

I think I will need some sort of tool for managing goals.

Goals will be available at every service tier but here some ideas for tier constraint

Free tier: less frequency, random goals are issued. Their rewards are of the least value. Daily logging in will be the primary goal for free tier, holiday related goals

Premium tier: daily and weekly goals, login goals as well as everything Free provides

Subscription: Everything the other tiers provide but also a beginning and end of the month goal that uses the personalization system 

# **Banking system**

1. Is only available for premium and subscription tier  
2. Should be accessible from TH

A user can create a bank account for a specific character type instance where they can save their currency so it doesn’t get wiped out on death.

 Subscription tier will have an additional feature, “quantum banking” which will  allow you to transfer currency for one character instances bank to another’s

# **Global stats (internal system I will operate)**

Internally I want a dashboard to gives me user behavior for the following

Popularity of character types, items and minions , when users are the most active in which regions. Also I want stats on who is posting their trading cards (to be further defined later in this doc) on social media platforms. 

# **Log feature of  users (internal system I will operate)**

A feature that categorizes , organizes, makes it searchable any events that I feel should be logged for a users awareness. It could be a new perk, upcoming special events , marketing , etc… essentially my message area to the users 

This layer is for all tiers 

However I have an idea for a subscription feature for users. Let’s call it the. “Advisor” which reviews what you could have done better in the last wave your character instance was in. It could also give you a weekly summary of how you played each character instance and suggestions on what you did well and what could have gone better. This is probably an extremely advanced feature for later on but if we should make architectural changes now for it I wanted you to know. I assume we will need to store all choices they made in features in the hub and a well as monitor how they did on the wave and what they should focus on in the TH  to improve for example the user has been taking the glass canon approach and while they do big number damage the die within x seconds if hit. Invest in dodge or armor or look for ways to mitigate through healing , consumables and life steal. Something like that we should be able to build some straight forward heuristics I would imagine 

# **Perks system**

This is going to be a nice personalization feature

I want a way to make the user experience unique to a user by being able to alter game play at this perks layer. I want the flexibility to do something like give a specific user a perk where every character they make during a certain period based upon some criteria gets an addition 10 hit points for example. Perks can be permanent or have specific duration. I should also be able to issue a deletion trigger to all clients if needed as well.

TH should have a feature where you can enter a code that may activate a perk that we use for marketing.I plan to have some schedule of regular perks to change up gameplay. Perks once activated can not be removed by any means  by the user unless they are configured to have duration and the perks self delete. 

Premium will be tbd on what perks when

But the subscription tier will get 1 perk a week that will always have a week duration so every week gameplay will change in subtle ways. It was always be a fun positive perk for gameplay

Perks will be all or nothing setting. You can opt out if you don’t want that uncertainty and you will not be presented with the perk at all.

Think of this as a scheduler for temporary mods I issue to the entire playerbase. The internal operator of this app  should have the ability to add and turn on and off when I want to some or all of our users based upon criteria I set when… eg a perk to users that are in Latin America for the day of the dead. I’ll probably need to build some builder app  or wizard to operate these effectively.

What key is I don’t want to have to deploy a new release to users I should be able to inject  a new perk event  from the backend to the mobile clients with and not force a new release on people. As well as remove it or deactivate when I wish to as well.

Ordering active perks could be very non deterministic so let’s add guard rails. Perks will be applied fifo but before we apply a perk we add perks in one of two ways we can either add the perk  to back so that it will get applied last or it will get added to the front and will be the first perk applied

Perks will have to have hooks in character instance creation , leveling, the store / black market / atomic vending machine , when the character instance is damaged in the wasteland , when a character instance damages a monster , when a character heals or steals life , when they move on the wasteland , when they die I think should cover most of the use cases on where we can inject perk behavior but feel free to make other suggestions.

This will use the personalization system to make these perks tailored to the user

# **Trading card for character instances**

1. This will be available every tier  
2. An idea i had was maybe there is a path for Free tier users to earn Premium by bringing in enough referrals?  
3. In general referrals should award users in game bonuses.  
   

A feature that generates a trading card of character type instances, all their stats , an image of that character with all their items and minions. The card could have multiple presentations. A roster feature from the TH that you can tab through to see all your characters or a catchy image suitable for posting on social media. The social media aspect could be part of marketing and we give the user options for referrals in the post , codes for new users to get perks , link to the game, etc… essentially an easy grass roots way for fans to member for us on whatever platform they use.

# **Special events system**

1. For Premium and Sub Tiers

The ability to create temporary and unique environmental changes in the wasteland.

Some ideas are 

Special unique buffs and debuffs that appear randomly on the wasteland  for the wave, items that drop only for these events, specially themed monsters  with special powers, changes in the environment such as acid pools, lava, “slow” fields where your speed is greatly reduced. Teleport traps to move you to a different part of the wasteland . 

I believe this is what you were sketching out for a much later phase.

# **Quantum Storage**

1. Subscription tier only  
2. 

Gives another option to the traders hub where you can move an item or minion from your character instance to storage that all your character instances can access it and take it out of the stash

I think a reasonable limitation here is you can move item 1x from one character instance to another and then it can’t go through quantum storage again

# **Minion system**

1. Premium and Subscription only   
   

Bots, pets, and contractors that will play by your side with different benefits and drawbacks 

Minions can level and increase their power of whatever effects they provide but they can’t use items. They can be damaged and can die. I think they should have a different leveling mechanism than character instances. Maybe we introduce rare food or items that trigger leveling

Each type of minion will be vulnerable to a specific type of damage mutant / melee / ranged  

You can only use 1 minion at a given time   
Minions will be stored in barracks feature accessible from TH.  
Minions are bound to a specific character instance not globally to all of the users characters 

# **Barracks system**

1. Premium and subscription tier only  
2. Premium gets 3 minions slots in total for all character type instances  
3. Subscription gets 1 additional minon slot for each character instance  
4. So 3 additional minions for premium, 1 alternate minon for each character instance in subscription mode.

Barracks are accessible from TH

# **Research an appropriate subscription price**

  I need some research on what an appropriate subscription price should be given the offerings i am planning, costs of this ongoing app business, and what current trends are for roguelite games like this in the market right now.

# **Assertion you can only enable the subscription in the premium app**

  Please think about the above assertion and let me know your thoughts? Should the path to subscription be only available in the premium version?

# **Character types and the user instances of them**

1. [https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters) 

We can use the above url as reference. 

I’d like some brainstorming on how we can differentiate between free, premium, sub with the number of instances allowed.

# **Atomic vending machine system**

1, subscription tier only.

This feature will offer 1x week a choice of 3 items that are uniquely tailored to your character of choice for sale. This can also include a unique minion

Accessible from TH

# **Black market system**

1. Premium and subscription tier 

 A store that has a smaller set of offerings but are at a higher tier of quality  and have a more inflated cost  
   
Accessible from TH

It will also very occasionally sell a curse removal scroll at a very high price 

# **Items & Store system**

Random items that alter game play get stocked in the store each time a user completes a wave

Can also contain reagents for the workshop   
Reroll of the items functionality for a fee   
You can also sell items in the store

Items can randomly drop from mobs. the higher the tier of mob the better quality drop. The character stat can impact drop chances (LUCK)

Items can be damaged and destroyed. They can not be repaired other than slowly in the Mrfixit appliance as part of the subscription tier idle game feature.

Items take damage on the characters death. They durability and can be destroyed when it reaches 0\.

Items can drop and be randomly cursed. A cursed item can’t be sold so if it has negative effects the character instance is stuck with them . The black market willl every so often offer a curse removal scroll that can remove the cursed attributed from the item.

Here is Brotato item system 

[https://brotato.wiki.spellsandguns.com/Items](https://brotato.wiki.spellsandguns.com/Items)

Items are bound to the character instance they were found in and are not globally accessible  to the user 

This will also be accessible from the TH

# **Stat system that impacts gameplay**

I like the one that Brotato uses

The stat system should introduce character leveling which will have bonuses based upon the character type .  Collecting currency  and killing mobs are used ways to level but would like other suggestions. Both things should have a point equivalent towards their next level. 

Here is Brotato s [https://brotato.wiki.spellsandguns.com/Stats](https://brotato.wiki.spellsandguns.com/Stats)

Id change elemental damage to mutant power which is a premium tier feature for some of our premium character types  
Mutant power will impact items that grant a passive mutant effect to the character or if the character type comes with a mutant effect  
Not all character types will have the mutant power stat

Death will randomly drop a stat by 1 point and death reset the amount they need to get to their next level.  
TH will have an advancement hall featrure where the character instances will be offered a random set of choices to select from for each level up they have accrued. The choices should be based upon the character type. Along with whatever bonuses that character type gets per level if any and of course perks can impact leveling.

Death will also 0 out any currency you have on you 

Please note how I want to run leveling deviates from what Brotato does.

# **Random monsters that drop recipes usable in the workshop or special reagents required to craft special temporary buffs or enhance weapons**

# **Cultivation chamber & Murder Hobo mode & mrfixit & minion fabricator system (IDLE GAME FOR SUBSCRIBERS)**

1. Subscription only   
   

Cultivation chamber  , while they are not playing they get some sort of benefit accumulation maybe something towards their stats. Where a single  character instance can  pick a stat and slowly increase it when you are offline the user can only pick 1 stat for 1 specific character instance.

We’d have to have some way to make sure this doesn’t cause some crazy edge cases and not break the game.

Murder Hobo mode. An option to accumulate game currency while offline. The single character instance can only be in  the cultivation chamber or murder hoboing at any given time not both. 

 MrFixit that will allow a character instance to repair 1 item very slowly. While it is in the mrfixit it can’t be used by the character instance and is removed from their inventory.

Minon Fabricator will store a pattern of the for a very high pricem  the higher the tier of the minion the higher the price. You can then create a clone of that minion for a very high price. Each time you clone the price is higher and the clone pattern is a random % less powerful than the last time pattern was used. When clone pattern viability (a stat which starts at 100 and loses that random amount of points each time a clone is made) reaches 0 the pattern is destroyed and removed.

# **Feature request system**

Let’s add some sort of system to really engage the user. I want to know their ideas for future features 

I think what I’d like to do with this is let ideas accumulate , then let people vote on the ideas every two weeks I’ll hold  tip goal for the the feature that got the most votes people will tip me money to prioritize that request and if I reach the tip goal say $1,000 I work on that feature first. 

I think this system will me  much mucher later one we start using BUT if it impacts current architectural decisions i wanted to discuss.

I may want to A/B test this system a bit and see if it is really viable.

We should also use this for a 1x month perk request at the premium tier. Let the users decide what the first perk of a next month it will be  a full week. If people do not participate then there is no guarantee what the first perk of the month will be. 

# **We need a achievement system\!**

	Some standard that that games of this type would do.

# **Controller support**

Let’s offer external controller support. Could we gate this as a premium feature?

Also do some research about supporting backbone hardware?  
