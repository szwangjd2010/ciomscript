[% IF !root.parameterDefinitions %]
   <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>

[% END %]
        <!-- auto injected begin - ciom rollback -->
        <hudson.model.ChoiceParameterDefinition>
          <name>DeployMode</name>
          <description>ciom DeployMode</description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
              <string>Deploy</string>
              <string>Rollback</string>
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>

        <hudson.model.ChoiceParameterDefinition>
          <name>RollbackTo</name>
          <description>ciom RollbackTo</description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
              [% FOR item = root.rollbackList %]
              <string>[% item %]</string>
              [% END %]
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>
        <!-- auto injected end - ciom rollback -->
[% IF !root.parameterDefinitions %]
      
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>

[% END %]