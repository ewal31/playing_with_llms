Just a simple repo to try [dspy](https://github.com/stanfordnlp/dspy) with some
models running locally via [ollama](https://ollama.com/).

`script.py` asks the same question 4 times, changing the expectations of the
answer. The answers should be:

* between 1 and 5 words
* at least 50 words
* relate to cates
* answered with a food

```bash
$> nix-shell --pure
$> python script.py

The question is:

What game was Super Mario Bros. 2 based on?

Short answer is:

Doki Doki Panic.

Long answer is:

Super Mario Bros. 2 was not based on any particular game. Instead, it
introduced new elements such as the ability to eat vegetables to gain
power-ups.

Cat based answer is:

Doki Doki Panic, which features Rare's mascots, the bear-like Marios
and the rabbit-like Luigis. This game was released in Europe as Super Mario
Bros. 2.

Food based answer is:

The game Super Mario Bros. 2 was based on Duck Hunt, which can be compared to a
dish made with duck meat.
```
