# Readability 规则

## High Non-Commenting Source Statements

<dl>
<dt>标识名</dt>
<dd>high_ncss</dd>
<dt>文件名</dt>
<dd>HighNonCommentingSourceStatements.swift</dd>
<dt>严重级别</dt>
<dd>Major</dd>
<dt>分类</dt>
<dd>Readability</dd>
</dl>


## Nested Code Block Depth

<dl>
<dt>标识名</dt>
<dd>nested_code_block_depth</dd>
<dt>文件名</dt>
<dd>NestedCodeBlockDepth.swift</dd>
<dt>严重级别</dt>
<dd>Major</dd>
<dt>分类</dt>
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
