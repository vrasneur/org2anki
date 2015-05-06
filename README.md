Org mode file to Anki deck
===

This script converts an Org mode file to a CSV file that can be used by the Anki SRS software.

It is a Ruby script and requires the 'org-ruby' library to parse the Org mode file.

Algorithm
---

Each time there is a text block under a headline:
- the Anki "question" is the list of the parent headlines and the headline itself
- the Anki "answer" is the text block

Example
---

The Org mode file

```
* a
  foo

** b
   bar

** c
   baz
```

will be converted to

```
* a;foo
"* a
* b";bar
"* a
* c";baz
```
