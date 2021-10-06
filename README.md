# HashCLI
Command-line Recursive Hasher written in AutoIt3

<pre>
Hash Digest Tool - ALBANESE Lab © 2018-2020

Usage: 
   HashCLI.exe [-c|r] --in &lt;file.ext&gt; [--alg &lt;algorithm&gt;] [--out &lt;file&gt;]

Options: 
   -c: Check a hash file
   -r: Recursive (Process directories recursively)

Parameters: 
   /alg: Algorithm
   /in : Input file
   /out: Output hash file

Algorithms: MD2, MD4, MD5, SHA1, SHA-256, SHA-384, SHA-512

Example: HashCLI.exe --in *.txt (Default MD5)
         HashCLI.exe --in *.txt --alg sha-256
         HashCLI.exe -r --in *.* --out Hash.md5
         HashCLI.exe -c --in Hash.md5
</pre>

## License
This project is licensed under the ISC License.
