## tuxtype-make-wordlist
Hey you!  
"Who? Me?"  
Yeah, you.  
Learning how to type (on Linux)? Want to play tuxtype but still haven't completed all the letters?  
**Then tuxtype-make-wordlist's makeWordList.sh is the right script for you!!!**

## Instructions:
* First, go to the directory where you've downloaded this script.
* Right click anywhere, and click *open in terminal*.
* In the terminal, call the script like so:
```shellscript
$ bash makeWordList.sh --interactive
```
* Answer the prompts that follow (press ENTER without typing anything for no answer).
* Done!

Just restart tuxtype and while choosing the word list (you know, the 'Animals', 'Planets' and other
stuff that shows up?), go to the next page using the arrow at the bottom and you'll see the new
word list file with the name **$USER [Keys: *keys_you_have_learned*]** where *$USER* is your username.

The script goes through the file
*/usr/share/dict/words* and *grep*-s all the words made from only the selected letters and create a
word list file (the level file) out of it, and copies that to *~/.tuxtype/words*.

```$ bash makeWordList.sh --help # for more available options```

And that's it!
Hope you have a lot of fun! :+1: :v:

![Adding this picture of baby Tux because he's so cute (and I need to learn markdown)](https://www.gnu.org/graphics/babies/BabyTuxAlpha.png)
