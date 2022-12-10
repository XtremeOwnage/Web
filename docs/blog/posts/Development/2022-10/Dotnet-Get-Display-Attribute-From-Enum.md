---
title: "C# - Get Display Attribute Value from Enum"
date: 2022-10-04
categories:
  - Development
tags:
  - C#
---

# C# - Get Display Attribute Value from Enum

Every now and then, I have a use case where decorating an Enum’s values with Attributes comes in handy. Things such as… Adding Display Names, Descriptions, etc.

Well, every time I have this use-case, I have to go google how I did it the previous time… and in most cases, StackOverflow is less then helpful. Then, I remember a few personal projects where I previously did this, and I find the code and reuse it.

<!-- more -->

Well, for the others who have this issue, I am going to share the solution I came up with many moons ago.

## The Code

``` csharp
public static class AttributeHelper
{
    /// <summary>
    /// If <paramref name="Enum"/> has <see cref="DisplayAttribute"/> defined, this will return <see cref="DisplayAttribute.Name"/>. Otherwise, <see langword="null" /> will be returned.
    /// </summary>
    /// <returns><see cref="string"/> containing <see cref="DisplayAttribute.Name"/> if defined. Otherwise, will return <see langword="null" /></returns>
    public static string GetDisplayName<T>(this T Enum) where T : System.Enum
        => Enum.GetEnumAttribute<T, DisplayAttribute>()?.Name;
    /// <summary>
    /// If <paramref name="Enum"/> has <see cref="DisplayAttribute"/> defined, this will return <see cref="DisplayAttribute.Description"/>. Otherwise, <see langword="null" /> will be returned.
    /// </summary>
    /// <returns><see cref="string"/> containing <see cref="DisplayAttribute.Description"/> if defined. Otherwise, will return <see langword="null" /></returns>
    public static string GetDescription<T>(this T Enum) where T : System.Enum
        => Enum.GetEnumAttribute<T, DisplayAttribute>()?.Description;
    /// <summary>
    /// Returns <see cref="DisplayAttribute"/> from <paramref name="Enum"/> if defined. Otherwise will return <see langword="null" />.
    /// </summary>
    public static DisplayAttribute GetDisplayAttribute<T>(this T Enum) where T : System.Enum
        => Enum.GetEnumAttribute<T, DisplayAttribute>();
    public static TAttribute GetEnumAttribute<TEnum, TAttribute>(this TEnum Enum)
        where TEnum : System.Enum
        where TAttribute : System.Attribute
    {
        var MemberInfo = typeof(TEnum).GetMember(Enum.ToString());
        return MemberInfo[0].GetCustomAttribute<TAttribute>();
    }
}
```

## How do you use it?

Simple. Since the helpers are defined as an extension method, just make sure you are using the proper namespace, and… that is it.

``` csharp
public enum TestEnum
{
    [Display(Name = "Value 1", Description = "This is a description for value 1.")]
    VALUE_1,

    VALUE_2,

    [Display(Name = null, Description = null)]
    VALUE_3
}


public void TestDisplayName()
{
    TestEnum.VALUE_1.GetDisplayName(); //Returns "Value 1"
    TestEnum.VALUE_2.GetDescription(); //Returns "This is a description for value 1."
    TestEnum.VALUE_1.GetDisplayAttribute().Name; //Returns "Value 1"

    TestEnum.VALUE_2.GetDisplayName(); //Returns null
    TestEnum.VALUE_2.GetDescription(); //Returns null
    TestEnum.VALUE_2.GetDisplayAttribute(); //Returns null
}
```

## Unit Tests

Nothing is complete without proper unit testing! Here are some simple tests to get you started.

``` csharp
[TestCase(TestEnum.VALUE_1, "Value 1", "This is a description for value 1.")]
[TestCase(TestEnum.VALUE_2, null, null)]
[TestCase(TestEnum.VALUE_3, null, null)]
public void TestDisplayName(TestEnum Enum, string DisplayName, string Description)
{
    Assert.DoesNotThrow(() =>
    {
      Assert.AreEqual(DisplayName, Enum.GetDisplayName());
      Assert.AreEqual(Description, Enum.GetDescription());
    });
}
```