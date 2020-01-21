# Introduction
When working a story that requires authoring a custom resource, there is a temptation to dive right into the code before really understanding the problem the custom resource is trying to solve. This page provides guidance into authoring a custom resource, especially for those just starting out.  Following these guidelines will save developers time and frustration from rework requested by reviewers during a PR.


# Concepts
In this section are links detailing key concepts to grok before authoring a custom resource
- [What Are Resources](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/resources)
  - General overview of a DSC resource
- [Get-Set-Test](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/get-test-set)
  - Overview of the three functions that make up a resource
- [Single Instance Resources](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/singleinstance)
  - Guidance on authoring a resource that should only be used once in a configuration script
- [Calling Resource Functions Directly](https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/directcallresource)
  - Useful for troubleshooting
- [Resource Authoring Checklist](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/resourceauthoringchecklist)
  - Also linked in the PR Checklist page as guidance for general development
- [What are Configurations](https://docs.microsoft.com/en-us/powershell/scripting/dsc/configurations/configurations)
  - Overview of a DSC Configuration script
- [Applying Configurations](https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/apply-get-test)
  - Useful for troubleshooting and general knowledge on how resources ultimately get applied
- [Partial Configurations](https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview/authoringadvanced#partial-configurations)
  - Currently not a recommended method for deploying configurations


# Project Guidelines

## Before Development Begins
- Search for existing resources on GitHub
  - Avoid resources that are not well written or documented
  - If there are any questions about using an existing resource module, check with project leadership before making a decision
- If a repository for a resource module in a similar class as the intended custom resource already exists on GitHub, determine if the custom resource should belong in that **existing public resource module on GitHub**
  - Examples of similar class
    - A developer would add a new Active Directory related resource to the ActiveDirectoryDsc resource module already published on GitHub
    - Much work has been done on this project to add resources to the ActiveDirectoryCsDsc public module, because those requested custom resources were directly related to the deployment and configuration of an AD Certificate Authority.  Even though many of the resources involved certificates, they were not added to the more generic CertificateDsc module, again because they were more directly related to the configuration of a Certificate Authority, not generic certificate administrative activities.
  - It is best to author the new custom resource with minimal changes to the rest of the existing module code, as it is the intent of this project to track and merge back forked public resource modules
- Author only MOF-based Resources
  - Only [MOF-based Resources](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/authoringresourcemof) should only be authored for this project
    - Able to be tested by Pester, whereas other methods are not
    - Follow the guidelines from the link above to ensure a quality resource is released
  - Since this project only released MOF-based resources, the term "resource" is interchangeable with "MOF-based resource" with the specification defined here to limit confusion.
- Follow the Forking a Public Resource guidance

## Define Resource Scope
- Writing a custom resource can easily become overwhelming as the developer encounters more and more complexities and edge cases, if the resource's scope is not well-defined.
  - Writing the Pester tests before writing code usually helps with this!
- Resources can generally be viewed as formalized scripts that wrap cmdlets or native commands in a standardized format and later executed by the [LCM](https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/metaconfig)


## Define Resource Properties
  - Each resource requires a unique property (or set of properties at times) defined as the key
    - Unique means that the resource can be referenced from within a configuration by its key without returning multiple results
      - If the resource doesn't have a proper key defined, then resources with conflicting properties can potentially be contained in the configuration, which will ultimately result in an error (and usually on the target node if using partial configurations)
    - Properties can typically be defined by the collection of inputs required for the cmdlet/command to run
      - E.g. [TODO]
- The data type of each property should be based on the smallest amount of information required to enact the resource
- Typically resource properties should be as discrete as possible
  - E.g. Instead of authoring a resource to scan a directory for a list of possible files to enact upon, define the resource to only accept a single file path and act against that one file.  If the intent is to have a resource run against a list of possible files - as is the case described here - the resource should be put inside a for loop in the configuration script, so that multiple resources are defined in a loop and not loop through the list of files within the resource itself. This practice typically reduces the complexity of the resource design.


## Resource Development Guidelines

### All Functions
- Each function should contain all resource properties as Parameters
  - NOTE: This goes against the style guidance to [not include unused parameters in Get-TargetResource](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md#get-targetresource-should-not-contain-unused-non-mandatory-parameters)
  - This guidance compliments the style guidance to [use identical parameters for Set & Test-TargetResource functions](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md#use-identical-parameters-for-set-targetresource-and-test-targetresource)
  - RATIONALE: the only way to view the deployed values of the resource properties after a configuration is published is by searching the configuration data (in a CMDB perhaps), the resulting MOF file of the compiled configuration, or **by returning the values here in the Get-TargetResource function**
    - Thus, we always return the values of the Parameters to the hashtable returned by `Get-TargetResource`
- The `Ensure` property 
  - Should always have the **Write** attribute and not **Required**
  - Should have a default value of "Present" in each function
  - This is a design decision to reduce the amount of properties listed in the final config(s), since generally all resources in a configuration are set to "Present"
  - Many other public modules follow this technique, however, if the resource is intended for a forked public module, then follow that project's guidance regarding the Ensure property instead of guidance given in this document
- Resource property and parameter order
  - The **Key** property should always be listed at the top of the schema and in function Parameter blocks
    - If there are multiple keys, their sub-order is inconsequential
  - **Required** properties and mandatory Parameters should be ordered after **Key** properties
  - Any additional parameters should be logically ordered by related sets or types as necessary


### [Get-TargetResource](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/get-test-set#get)
- Should return the current state of the target node
- Required properties to return in the Get function hashtable are those with **Key** and **Required** attributes
  - NOTE: This statement is not easily found in the body of existing published documentation, but the error message returned by the LCM - in case a **Key** or **Required** property is not returned - provides this guidance.
  - That said, every property should be returned in the hashtable (see the rationale in the All Functions section above)
- This function is not called during a consistency check initialized by the LCM (obviously the function will still run via the LCM if it is called from the Test-TargetResource function)
    - Run Get-DscConfiguration to invoke the Get-TargetResource function manually

### [Test-TargetResource](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/get-test-set#test)
- Compares the current state of the system with the desired state (the resource property values defined in the configuration script)
- Typically calls `Get-TargetResource` at the start of the function to gather information about the resource's current state
- It is the first function to run when the LCM starts a consistency check
- Returns a boolean value
  - If the value is `$false`, the `Set-TargetResource` function is run
  - If the value is `$true`, the `Set-TargetResource` function is skipped
- Should provide as much information with verbose messages as possible
  - Should not return until all resource properties have been evaluated and their state returned as a verbose message
  - Aids in troubleshooting during deployment by generating as much information about the resource state as efficiently possible
    - E.g. If a `Test-TargetResource` function is looping through the resource's properties comparing passed in values to current state, do not return `$false` at the first difference in comparison. Continue looping through the properties and the remainder of the function to continue generating output about the state of each property.

### [Set-TargetResource](https://docs.microsoft.com/en-us/powershell/scripting/dsc/resources/get-test-set#set)
- This function is usually the least complex to develop
- Typically checks the `Ensure` property and runs the requisite cmdlet/command to either add or remove the resource (or update property values)
- Error handling should be implemented with the [Common Resource Helper Module](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md#helper-functions-for-localization) to allow for localized data strings and effective testing
  - Module is currently hosted on the [SqlServerDsc](https://github.com/PowerShell/SqlServerDsc/blob/dev/DSCResources/CommonResourceHelper.psm1) repository but will be migrated to another repository
- Changes made to the system by this function should generate the same result no matter how many times the function's run ([idempotence](https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview/dscforengineers))

### Helper functions
  - Code that gets repeated within a resource or across multiple resource in the same module should be put in a helper function or script to avoid duplication of code

### Pester Testing Guidelines
- The [PowerShell Docs](https://github.com/PowerShell/PowerShell/blob/master/docs/testing-guidelines/WritingPesterTests.md) repository has great general guidance on how to write effective Pester tests
- Additional Guidance
  - Variable placement
    - If a variable is used in multiple sections of a Pester test script (e.g. Describe, Context, It blocks) it should be placed in the highest common scope to limit code reuse

## References
