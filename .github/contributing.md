# Background 

From time to time, our team writes ad hoc scripts to help them throughout their days. Git's a great place for stashing such tools for later use and/or sharing them with teammates. Little in this project is meant to be a spiffy "product" type of offering. Everything is provided "as is".

Translation: *Use at your own risk.*

# How to Contribute

Tool-users may feel free to sumbit issue requests and PRs to this project. That said, due to the aforementioned nature of this project, issue requests are unlikely to receive much traction absent an associated PR. So, if you find a tool in this repo useful but think that it should do more ...or even just be a bit less rough around the edges, please feel free to fork this repository and PR changes back. 

## Testing

Due to the nature of this project, formalized testing is not currently done. If you would like to see validation included in this project, please open a PR to have testing-contributions merged into the project.

## Submitting Changes

Prior to opening a pull-request, we prefer that an associated issue be opened - you can request that you be assigned or otherwise granted ownership in that issue. The submitted pull-request should reference the previously-opened issue. The pull-request should include a clear list of what changes are being offered (read more about [pull requests](http://help.github.com/pull-requests/)).

Please ensure that commits included in the PR are performed with both clear and concise commit messages. One-line messages are fine for small changes. However, bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    >
    > A paragraph describing what changed and its impact."

## Coding conventions

Start by reading the existing code. We tend to optimize for narrower terminal widths - typically 80-characters (the individual who originated the project has some ooooold habits) but sometimes 120-character widths may be found. We also typically optimize for UNIX-style end-of-line (exception being the contents of the `powershell` directory). Note that the project-provided `.editorconfig` file should help ensure appropriate behavior.

For shell scripts conventions are fairly minimal
    * Pass your script through a tool like [shellcheck](https://www.shellcheck.net/)
    * Use three-space indent-increments for basic indenting
    * If breaking across lines, indent following lines by two-spaces (to better differentiate from standard, three-space indent-blocks) - obviously, this can be ignored for here-documents..
    * Code should be liberally-commented.
       * Use "# " or "## " to prepend.
       * Indent comment-lines/blocks to line up with the blocks of code being commented
    * Anything not otherwise specified - either explicitly as above or implicitly via pre-existing code - pick an element-style and be consistent with it.
