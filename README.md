## tuxtype-make-wordlist
Hey you!  
"Who? Me?"  
Yeah, you.  
Learning how to type (on Linux)? Want to play tuxtype but still haven't completed all the letters?  
**Then tuxtype-make-wordlist's makeWordList.sh is the right script for you!!!**

## Scripts, how do they work?
* First, go to the directory where you've downloaded this script.
* Right click anywhere, and click *open in terminal*.
* In the terminal, call the script like so:
```shellscript
$ bash makeWordList.sh asdf
```
* Instead of 'asdf', just enter the *alphabetic* keys that you have learned.

The script will go through the file
*/usr/share/dict/words* and *egrep* all the words made from only the selected letters and create a
word list file (the level file) out of it, and will copy that to *~/.tuxtype/words*.

Just restart tuxtype and while choosing the word list (you know, the 'Animals', 'Planets' and other
stuff that shows up?), go to the next page using the arrow at the bottom and you'll see the new
word list file with the name **$USER [Keys: *keys_you_have_learned*]** where *$USER* is your username.

## But wait! There's more!!
If you have learned some special marks and numbers and want to practice those too, here is how you do it:
* In the terminal, after the alphabetic keys, give a space and enter all the special keys inside single quotes:
```shellscript
$ bash makeWordList.sh asdf '78293#$"{}'
```
* **Do not forget to put single quotes around the non-alphabetic keys.**
* You can not have single quotes (') in the non-alphabetic-keys part there.  
  If you enter double-quote ("), the script will also include a single-quote (') for you to practice.

## The Final Syntax:
```shellscript
$ bash makeWordList.sh alphabeticKeys ['non-alphabetic_keys enclosed in single quotes']
```
* Just in case you're confused by the brackets there ([]), it just means that is optional. Do **not** type the brackets in.

## Known Issues:
* The script does take a LOT of time to execute. It isn't an endless-loop, but this issue needs to be fixed.

And that's it!
Hope you have a lot of fun! :+1: :v: 

![Adding this picture of baby Tux because he's so cute (and I need to learn markdown)](https://www.gnu.org/graphics/babies/BabyTuxAlpha.png)
