    [% IF !root.existParameterDefinitions %]
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
    [% END %]
        <!-- auto injected begin - ciom rollback -->
        <hudson.model.ChoiceParameterDefinition>
          <name>DeployType</name>
          <description></description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
              <string>Deploy</string>
              <string>Rollback</string>
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>

        <hudson.model.ChoiceParameterDefinition>
          <name>DeployType</name>
          <description></description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
            [% FOREACH item in root.rollbackList %]
              <string>[% item %]</string>
            [% END %]
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>
        <!-- auto injected end - ciom rollback -->
    [% IF !root.existParameterDefinitions %]
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
    [% END %]