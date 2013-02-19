Uploading files into namecoin blockchain
==============

Do you want to host your files of any legality (almost) anonymously and more importantly, for absolutely forever with no feasible way to delete them? (Even when the upload is *nightmaringlishly* slow?)

Upload them to namecoin blockchain!

Usage
-------------

     ./download.pl damselflyjpg damselfly.jpg
     
This will download the 2MB image of damselfly that I got from wikipedia and save it to damselfly.jpg on your disk.

Other files currently uploaded to blockchain are named "nevermore" with the Edgar Alan Poe's poem The Raven (uploaded by me) and "therealraven" with excerpt from Thomas Holley Chivers' poem Appolo (uploaded by someone who noticed my domain registrations, cheers to that guy).

    ./upload.pl file.txt unique_name_of_file
    
This will upload the file.txt to blockchain, it takes about 20 minutes (or about 90 minutes if you want to be sure it was uploaded correctly).

However, sometimes it can take even longer, probably based on how willing are other nodes in the network. 

(Right now, I am trying to upload these scripts themselves to blockchain. I am now waiting 1 hour for even the name_new operation to appear in the blockchain. Is it possible that the miners blacklisted me now? Hm, we will see. Maybe it's because they are "fresh" namecoins? Well, it is simply *nightmaringlishly* slow :) )

Don't upload bigger files than few bytes/kilobytes though; read further why.

Installation
-------------
This reliably works only on linux with base64 program installed (you should have it though) and with perl installed. It can probably run on other unix-like systems and cygwin, I have no idea though.

You need to install namecoin first and then let it update to the latest block in blockchain. You can read the instructions on namecoin website - http://dot-bit.org/InstallAndConfigureNamecoin . You have to have namecoind running.

You also need buy some namecoins - they are now for basically free on https://exchange.bitparking.com/ , altough the price may change. 100 NMC for some basic experimentation is more than enough.

The namecoins should also be confirmed enough for miners to take them, so make that another few hours.

You need to set NAMECOIN_PATH env value to the path where namecoind is located; I do it usually like this
    
    cd ~/path/to/namecoind
    export NAMECOIN_PATH=$(pwd)

Then you are all set. 

WARNING
==============
Uploading works reliably **ONLY** on smaller files.

Probably because I am abusing namecoind for something it is not meant to do :), for bigger files, it takes **ages** doing god-knows-what on bigger files. (Bigger meaning bigger than about 50 kB.)

In short, when presented with 5 thousand name_firstupdate operations at the same time, `namecoind` starts to take inappropriate amount of resources and starts to be *really, really slow*.

When I tried to upload the 2MB picture on my weaker computer, it took the computer down. When I tried it on stringer computer, it took 2 days, ate about 30GB of space on disk and 3GB of RAM; after restarting `namecoind`, it was still slow and useless. Again, it's not an error in my script, it's something with `namecoind`, but I don't really understand what goes under the hood to fix it.

How I do it
-------------------

I convert the file to base64 and then split it into 400 characters long strings. (400 because the namecoin values are limited to 520bytes, so I get some reserve.) 

Then, I put each part of the file into a separate "namecoin domain" in the "namecoin namespace" fp/ (as in "file part") with a random name, together with the pointer to the next part. 

And as the last thing, I create a new "namecoin domain" in the namespace fb/ (as in "file begin") with the name of the file, and in the value, I point to the name of the domain with the first part of the file.

However, it is right now very unefficient because namecoind itself is not built for that. So, if someone understands namecoind core and can rewrite it so it doesn't waste gigabytes of disk space and memory, it would be great.

Why I did it
------------------
I researched into namecoin and it striked me as a great way to store key-value pairs easily and anonymously.

You got such a cool system and people use it for just *storing IP addresses*? That is **so boring**...

I first thought about implementing some sort of primitive social network on top of it, but then I found out I will have to save bigger informations than 400 bytes anyway; and then I realized if I will have the means to save *that*, I will have the means to save *anything*. So I built that, first :)

I personally think this is kind of big - you can now save anything, from whenever you want, simply, and forever. I am thinking some distribution of torrent magnets and so on, but it can be also used for messages where you really want to stay anonymous (I thought more decentralized version of pastebin), it can be used for building primitive blogging system (once I - or someone else :) - add support for rewriting the files), it can be used for anonymous remote command and control (yeah, that's a little illegitimate), it can be used for anonymously distributing torrents, etc etc.

Of course there are downsides - first, the file is in the blockchain :), so you are basically forcing everyone to download everything ever posted there. I have no idea how - if - will this scale.

Second - it's not for free. And I can imagine that - if this becomes popular, the cost of the needed fees will be non-trivial.

Why not a separate blockchain?
-----------------
Why do I litter namecoin blockchain instead of creating a fork? Well, that is a good question, but I would need to solve issues like IRC bootstraping and getting people to actually mine coins, so no, that's not going to work.

About the code, about me
------------------
The code is under BSD licence. (C) Karel Bílek, 2013.

My name is Karel Bílek, I am an occasional hacker, computational linguist, member of a Czech Pirate Party and who knows what else.

Contact me at kb@karelbilek.com , send me bitcoins to 1CrwjoKxvdbAnPcGzYjpvZ4no4S71neKXT if you want.
