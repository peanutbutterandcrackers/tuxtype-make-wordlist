## tuxtype-make-wordlist
Hey you!  
"Who? Me?"  
Yeah, you.  
Learning how to type (on Linux)? Want to play tuxtype but still haven't completed all the letters?  
**Then tuxtype-make-wordlist is the right script for you!!!**

## Instructions:
* First, go to the directory where you've downloaded this script.
* Right click anywhere, and click *open in terminal*.
* In the terminal, call the script like so:
```shellscript
$ bash tuxtype-make-wordlist --interactive
```
* Answer the prompts that follow (press ENTER without typing anything for no answer).
* Done!

Just restart tuxtype and while choosing the word list (you know, the 'Animals', 'Planets' and other
stuff that shows up?), go to the next page using the arrow at the bottom and you'll see the new
word list file with the name **$USER [Keys: *keys_you_have_learned*]** where *$USER* is your username.

The script goes through the file
*/usr/share/dict/words*, *grep*-s all the words made from only the selected letters, creates a
word list file (the level file) out of it, and copies that to *~/.tuxtype/words*.

```$ bash tuxtype-make-wordlist --help # for more available options```

## Installation:
* Local Installation (for the current user only):
```shellscript
$ bash INSTALL.sh
```
* Global Installation (for all users - requires superuser privileges):
```shellscript
$ sudo bash INSTALL.sh --global
```

And that's it!
Hope you have a lot of fun! :+1: :v:

### P. S:
Use ``gtypist`` to learn how to touch type - ```sudo apt install gtypist``` - and this script to generate the word list from the keys you have just learned to practice on ```tuxtype```, that way, you'll have cemented your knowledge very well before moving on to next lesson in ```gtypist```. But make sure you do not over-play/over-cement your knowledge. You wouldn't want your typing to be fast for a certain set of keys and slower for the next set - esp. while learning. Trust me.

![Adding this picture of baby Tux because he's so cute (and I need to learn markdown)](https://www.gnu.org/graphics/babies/BabyTuxAlpha.png)
