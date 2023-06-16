# openkore-plugin-jsontodiscord

Simple openkore plugin that makes use WebService::Discord::Webhook, to send a status update from openkore to your discord server.
Helpful for monitoring when you are running the bot from another pc/vps.

Code snip below is a sample output when used as a standalone, it would be in json format and not nice to the eyes
`{"#Deaths":0,"CX":180,"CY":76,"Exp/hr":7969,"Hp":"93.81","Lockmap":"pay_fild08","Map":"pay_fild08","Name":"Lovel","Username":"username010","Weight":"23"}`

Picture below is how it would look like IF used in tandem with a discord bot that receives the messages and deletes each incoming message so the server wont be flodded with messages.

![discord plugin](https://github.com/KoukatsuMahoutsukai/openkore-plugin-jsontodiscord-main/assets/123940777/f36e717f-7cb7-45f5-a876-d42b24f31bc1)

This adds complexity though and would need more setup so if you want the simple webhook message i suggest the code from sctnightcore which is where i copied most of the code.
https://github.com/sctnightcore/OpenKorePluginsByMe/blob/master/OpenkoreToDiscord


for those intereseted in the bot that organizes the messages i am working on it and a tutorial so i can share it with you in the following days. 
in the meantime you can use this plugin then maybe code your own discord bot too

## Requirements
-openSSL

-https://metacpan.org/pod/WebService::Discord::Webhook

-https://metacpan.org/pod/HTTP::Tiny

-https://metacpan.org/pod/JSON

-https://metacpan.org/pod/Net::SSLeay

-https://metacpan.org/pod/IO::Socket::SSL


Honestly i had difficulties installing the requirements on windows, i would provide a dockerfile/docker image later on that would make you not bother with the requirements.

## Usage
1.  Change the `my $url`, simply paste your webhook url from discord there
    
    https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks

2.  paste the jsontodiscord folder inside the plugins folder of your openkore

3.  add the jsontodiscord plugin in the sys.txt inside control folder, the line is like below
    `loadPlugins_list raiseStat,raiseSkill,reconnect,item_weight_recorder,xconf,eventMacro,macro,jsontodiscord`

    It should work right away if the requirements are installed properly, but i suggest just using the docker that im about to upload if you are not familiar with installing the requirements,
    modifying the stats that you want to see can also be easy i would upload a tutorial for it later on.

## Customizing

proceed to the code block below and you can modify this as much as you want, just copy one line say `'Name'      => $char->{name},` paste it on the next line and modify the contents.

the 'Name' is the string label while `$char->{name}` is a variable in the memory of openkore,

theres listed values of these in wikis or in forums but a good place to start is inside your own openkore plugins, browse to `\plugins\needs-review\webMonitor\trunk` and open the `webMonitorServer.pm` 

using your text editor of choice, line 564 onwards has alot of different variables to play with

```
my $data = {
            'Username'  => $config{username},
            'Name'      => $char->{name},
            'Hp'        => sprintf("%.2f", $char->hp_percent()),
            'Weight'    => sprintf("%.0f", $char->weight_percent()),
            '#Deaths'   => (exists $char->{deathCount} ? $char->{deathCount} : 0),
            'Exp/hr'    => $bExpPerHour,
            'Lockmap'   => $config{lockMap},
            'CX'        => $char->position()->{x},
            'CY'        => $char->position()->{y},
            'Map'       => $field->name
        };
```
