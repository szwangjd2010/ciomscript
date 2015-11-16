
// Demonstrate InetAddress. 
import java.net.*; 

class test 
{ 
	public static void main(String args[]) throws Exception { 
		InetAddress Address = InetAddress.getLocalHost(); 
		System.out.println(Address); 
		
		Address = InetAddress.getByName("starwave.com"); 
		System.out.println(Address); 
		
		InetAddress SW[] = InetAddress.getAllByName("www.nba.com"); 
		for (int i=0; i<SW.length; i++) {
			System.out.println(SW[i]);
		}
	}
}