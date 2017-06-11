# Readability Rules

## High Non-Commenting Source Statements

<dl>
<dt>Identifier</dt>
<dd>high_ncss</dd>
<dt>File name</dt>
<dd>HighNonCommentingSourceStatementsRule.swift</dd>
<dt>Severity</dt>
<dd>Major</dd>
<dt>Category</dt>
<dd>Readability</dd>
</dl>


## Nested Code Block Depth

<dl>
<dt>Identifier</dt>
<dd>nested_code_block_depth</dd>
<dt>File name</dt>
<dd>NestedCodeBlockDepthRule.swift</dd>
<dt>Severity</dt>
<dd>Major</dd>
<dt>Category</dt>
<dd>Readability</dd>
</dl>

This rule indicates blocks nested more deeply than the upper limit.

##### Thresholds:

<dl>
<dt>NESTED_CODE_BLOCK_DEPTH</dt>
<dd>The depth of a code block reporting threshold, default value is 5.</dd>
</dl>

##### Examples:

###### Example 1

```
if (1)
{               // 1
    {           // 2
        {       // 3
        }
    }
}
```
