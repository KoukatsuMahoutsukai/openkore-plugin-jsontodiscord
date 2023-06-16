############################
# Openkore -> Discord[Webhook]  plugin for OpenKore by sctnightcore & alisonrag
# This software is open source, licensed under the GNU General Public
# License, version 2.
# Whenever the bot recives , it will forward to Discord
# Use at your own risk.
# This plugin should be in a subfolder of plugins like 'plugins/jsontodiscord/jsontodiscord.pl'.
# code mostly came from sctnightcore's plugin, modified it for my personal use.
############################

package jsontodiscord;

use strict;
use WebService::Discord::Webhook;
use Plugins;
use Utils qw( existsInList getFormattedDate timeOut makeIP compactArray calcPosition distance);
use Time::HiRes qw(time sleep);
use Log qw(warning message error debug);
use I18N qw(bytesToString);
use Globals;
use Misc;
use JSON::Tiny qw(encode_json);

#   !!Important to replace this with the url of your own webhook, otherwise info wont be sent to your discord
my $url = 'https://discord.com/api/webhooks/';

my $webhook = WebService::Discord::Webhook->new( $url );

#   attempts to send a message every time status changed, however it wont send if timer isnt reached. 
#   this avoids spamming discords server, as without the timer it sends maybe 5 to 10 every second per bot.
my $hooks = Plugins::addHooks(
		['changed_status', \&hp]
);

my $lastCallTime = 0;

#   change the min max to your desired timer, it would pick a value in between. I used a large initial value to avoid rate limiting since i use multiple bots.
my $minInterval = 70;  # Minimum interval in seconds
my $maxInterval = 110;  # Maximum interval in seconds

#   only picks a random value once upon initialization, if you want a different value every call then place this inside the subroutine hp
my $randomInterval = int(rand($maxInterval - $minInterval + 1)) + $minInterval;

sub hp {
    my $currentTime = time();
    my $intervalc = int($currentTime - $lastCallTime);
    if ($intervalc > $randomInterval) {
        $lastCallTime = $currentTime;
        
        my ($endTime_EXP, $bExpPerHour, $w_sec);
        $endTime_EXP = time;
        $w_sec = int($endTime_EXP - $startTime_EXP);
        # Check if $w_sec is non-zero before performing the division
        if ($w_sec != 0) {
            $bExpPerHour = int($totalBaseExp / $w_sec * 3600);
        } else {
            # Handle the case when $w_sec is zero (optional)
            $bExpPerHour = 0;  # or any other appropriate value
        }
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
        my $json_data = encode_json($data);
        discordnotifier($json_data);
    }
}

sub discordnotifier {
    my ($msg) = @_;

    eval {
        $webhook->execute(content => $msg);
    };

    if ($@) {
        my $error = $@;
        if ($error =~ /code: (\d+)/) {
            my $error_code = $1;
            print "Error sending Discord message: HTTP ERROR $error_code\n";
        } else {
            print "Error sending Discord message: $error\n";
        }
        return;  # or exit if needed
    }
}

sub onUnload {
    Plugins::delHooks($hooks);
}


Plugins::register('jsontodiscord', 'Forwards received to Discord.', \&onUnload);
