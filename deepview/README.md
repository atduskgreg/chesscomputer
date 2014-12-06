## DeepView Web App

### Current Status

* "/" renders a homepage with just a link to the upload form
* "/upload" renders an erb template presenting an upload form
* POST "/pgn" receives the upload of the pgn file, parses it, and renders a template with the pgn data 