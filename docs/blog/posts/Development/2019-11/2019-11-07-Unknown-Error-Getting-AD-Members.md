---
title: "Unknown error (0x80005000) – Getting AD Group Members"
date: 2019-11-07
categories:
  - Development
tags:
  - Development/C#
  - Development/.NET
---

# Unknown error (0x80005000) – Getting AD Group Members

Earlier today, somebody asked me to help troubleshoot a piece of code which was randomly erroring out- with a very undescriptive exception, only containing `Unknown error (0x80005000)`

The code in question, was recurring over groups, to gather membership. After ruling out permissions issues, I decided to try and replicate what was happening.

<!-- more -->

## Replicating the issue

Here is my test code, designed to replicate the functionality of the code in question:

``` csharp
using (var adc = new PrincipalContext(ContextType.Domain, "mydomain.com"))
{
    UserPrincipal filter = new UserPrincipal(adc);
    filter.SamAccountName = "FakeUser";

    //get user principal
    PrincipalSearcher search = new PrincipalSearcher(filter);
    var ME = search.FindAll().OfType<UserPrincipal>().First();

    //query user's groups
    var x = ME.GetGroups();

    //loop through user's groups
    foreach (var grp in x.OfType<GroupPrincipal>().Where(o => o.Name.StartsWith("test", StringComparison.OrdinalIgnoreCase)))
    {
        grp.SamAccountName.WriteConsole();

        "Looking at the group's members".WriteConsole();
        //Loop through each group member
        foreach (var obj in grp.Members)
        {
            ("\t" + obj.Name).WriteConsole();

        }

        "Looking at groups inside of the groups, using the GetGroups() Method".WriteConsole();
        try
        {

            //Loop through groups in group.
            foreach (var subgrp in grp.GetGroups())
            {
                $"\t\t{subgrp.SamAccountName}".WriteConsole();
            }
        }
        catch (Exception ex)
        {
            $"\t\tIt broke: {ex.Message}".WriteConsole();
        }
    }
}
```

Here is the output:

```
Starting timed workflow.
------------------------------------------------------------------------------------------------------------------------
TEST_Group_EVIL
Looking at the group's members
        User, Fake
Looking at groups inside of the groups, using the GetGroups() Method
                It broke: Unknown error (0x80005000)
TEST_GROUP_NOT_EVIL
Looking at the group's members
        User, Fake
Looking at groups inside of the groups, using the GetGroups() Method
------------------------------------------------------------------------------------------------------------------------
Completed in 0m 55s 318ms
Please initiate ctrl+c to exit program.
```


The particular method throwing the exception is Principal.GetGroups();

While- it is not clear in my above example why- let me demonstrate the exact reason… with a screenshot of the accounts.

![](assets/group-with-slashes.png)

That’s right. The “EVIL” group contains slashes.

While Active Directory WILL let you create groups with slashes, it will warn you, that you should not do this.

The error is being thrown inside of the code from GetGroups(), likely coming from code that is not able to properly handle the forward slash.

## How to resolve/fix this issue?

1. Don’t create groups with slashes. Seriously, it is a very bad practice and will only cause issues.
2. Don’t use the GetGroups() method. Instead- look at Group.Members.OfType<GroupPrincipal>().