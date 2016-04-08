<!--- 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 ---><cfcomponent extends="org.lucee.cfml.test.LuceeTestCase">
	<cfscript>
		
	//public function afterTests(){}
	
	public function setUp(){
		variables.has=defineDatasource();
	}


	private boolean function defineDatasource(){
		var pgsql=getCredencials();
		if(pgsql.count()==0) return false;
		application action="update" 
			datasource="#{
	  class: 'org.postgresql.Driver'
	, bundleName: 'org.lucee.postgresql'
	, bundleVersion: '8.3.0.jdbc4'
	, connectionString: 'jdbc:postgresql://#pgsql.server#:#pgsql.port#/#pgsql.database#'
	, username: pgsql.username
	, password: pgsql.password
}#";
	
	return true;
	}

	private struct function getCredencials() {
		// getting the credetials from the enviroment variables
		var pgsql={};
		if(
			!isNull(server.system.environment.POSTGRE_SERVER) && 
			!isNull(server.system.environment.POSTGRE_USERNAME) && 
			!isNull(server.system.environment.POSTGRE_PASSWORD) && 
			!isNull(server.system.environment.POSTGRE_PORT) && 
			!isNull(server.system.environment.POSTGRE_DATABASE)) {
			pgsql.server=server.system.environment.POSTGRE_SERVER;
			pgsql.username=server.system.environment.POSTGRE_USERNAME;
			pgsql.password=server.system.environment.POSTGRE_PASSWORD;
			pgsql.port=server.system.environment.POSTGRE_PORT;
			pgsql.database=server.system.environment.POSTGRE_DATABASE;
		}
		// getting the credetials from the system variables
		else if(
			!isNull(server.system.properties.POSTGRE_SERVER) && 
			!isNull(server.system.properties.POSTGRE_USERNAME) && 
			!isNull(server.system.properties.POSTGRE_PASSWORD) && 
			!isNull(server.system.properties.POSTGRE_PORT) && 
			!isNull(server.system.properties.POSTGRE_DATABASE)) {
			pgsql.server=server.system.properties.POSTGRE_SERVER;
			pgsql.username=server.system.properties.POSTGRE_USERNAME;
			pgsql.password=server.system.properties.POSTGRE_PASSWORD;
			pgsql.port=server.system.properties.POSTGRE_PORT;
			pgsql.database=server.system.properties.POSTGRE_DATABASE;
		}
		return pgsql;
	}



</cfscript>
	<cffunction name="test">
		<cfquery name="qry">
			CREATE OR REPLACE FUNCTION f_is_bigint(IN in_value bigint, OUT out_is_bigint boolean, OUT out_value bigint)
			  RETURNS record AS
			$BODY$
			DECLARE
			BEGIN
			out_value = in_value;
			IF in_value IS NULL THEN
			out_is_bigint = false;
			END IF;
			perform in_value::bigint;
			out_is_bigint = true;
			EXCEPTION WHEN others THEN
			out_is_bigint = false;
			/*
			SELECT * FROM f_is_bigint(9223372036854775807);
			SELECT * FROM f_is_bigint(9223372036854775808);
			*/
			END;
			$BODY$
			  LANGUAGE plpgsql VOLATILE
			  COST 100;
			--ALTER FUNCTION f_is_bigint(bigint)
			--  OWNER TO postgres;
		</cfquery>


		<cfstoredproc procedure="f_is_bigint" debug="yes">
		<cfprocparam type="In" cfsqltype="CF_SQL_BIGINT" value="2147483649" null="no">
		<!--- result set --->
		<cfprocresult name="data3">
		</cfstoredproc>


		<cfset assertEquals(true,isQuery(data3))>
		<cfset assertEquals(1,data3.recordcount)>
		<cfset assertEquals("out_is_bigint,out_value",data3.columnlist)>
		<cfset assertEquals(1,data3.out_is_bigint)>
		<cfset assertEquals(2147483649,data3.out_value)>
	</cffunction>
</cfcomponent>