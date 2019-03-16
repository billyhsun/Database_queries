import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
	try {
            this.connection = DriverManager.getConnection(url, username, password);
            connection.setSchema("parlgov");
        }
        catch ( SQLException err ) {
            System.out.println("Could not connect to the database");
            return false;
        }
	return true;
    }

    @Override
    public boolean disconnectDB() {
        try {
            this.connection.close();
        }
        catch ( SQLException err ) {
            System.out.println("Could not close the database");
            return false;
        }
	return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
	try {
		// Returns all elections and cabinets for country countryName in descending order by election date
		PreparedStatement query = connection.prepareStatement("SELECT election.id, cabinet.id FROM cabinet, election," + 
		" country WHERE country.name = ? AND cabinet.election_id = election.id AND " + 
		"cabinet.country_id = country.id ORDER BY election.e_date DESC");
            	query.setString(1, countryName);
            	ResultSet set = query.executeQuery();
            	ArrayList<Integer> cabinet = new ArrayList<>();
            	ArrayList<Integer> election = new ArrayList<>();
           	while (set.next()) {
                	election.add(set.getInt(1));
                	cabinet.add(set.getInt(2));
           	}
           	return new ElectionCabinetResult(election, cabinet);
        } catch (SQLException e){
           	System.out.println("Could not complete");
          	 e.printStackTrace();
        	   return null;
	}
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        ArrayList<Integer> res = new ArrayList<>();
        try {
		// Returns pairs with politicianName and all the other presidents with their comments and descriptions
        	PreparedStatement query = connection.prepareStatement("SELECT pres2.id, CONCAT(pres1.description, ' ', pres1.comment) " +
                    "as compare1, CONCAT(pres2.description, ' ', pres2.comment) as compare2 " +
                    "FROM politician_president pres1, politician_president pres2 " +
                    "WHERE pres1.id = " + politicianName + " AND pres1.id <> pres2.id");
            ResultSet set = query.executeQuery();
            while (set.next()) {
		// Checks that the similarities are high enough, if so then add to the result.
                if (similarity(set.getString(2), set.getString(3)) > threshold){
                    res.add(set.getInt(1));
                }
            }
            return res;
        } catch (SQLException e) {
	    System.out.println("Could not complete");
            e.printStackTrace();
            return null;
	}
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        // System.out.println("Hello");
    }

}

