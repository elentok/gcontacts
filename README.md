gcontacts
=========

NodeJS module to work with google contacts.

Usage
------

First, install the package:

```bash
npm install gcontacts
```

Then you can use the following code:

```coffee

GoogleContacts = require 'gcontacts'

gcontacts = new GoogleContacts(
  email: 'me@gmail.com'
  password: '1234')

gcontacts.connect (err) ->
  gcontacts.getContacts (err, page) ->
    for contact in page.contacts
      console.log contact
```
