    <Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"
		connectionTimeout="40000"
		redirectPort="8443"
		uRIEncoding="utf-8"
		enableLookups="false" 
		disableUploadTimeout="true"
		acceptCount="500"
		maxThreads="1000"
		maxProcessors="1500"
		compression="on"
		compressionMinSize="2048"
		compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain"
    />

