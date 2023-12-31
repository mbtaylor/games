
import java.util.Arrays;
import java.util.Random;
import uk.ac.starlink.ttools.jel.StateDependent;

public class Game {

    private static final Random rnd_ = new Random();

    @StateDependent
    public static int keep( int r, int k, boolean isExplode ) {
        int[] rolls = new int[ r ];
        for ( int i = 0; i < r; i++ ) {
            rolls[ i ] = d10();
        }
        Arrays.sort( rolls );
        int total = 0;
        for ( int i = r - k; i < r; i++ ) {
            int c = rolls[ i ];
            total += isExplode ? maybeExplode( c ) : c;
        }
        return total;
    }

    @StateDependent
    public static int d10() {
        return 1 + rnd_.nextInt( 10 );
    }

    private static int maybeExplode( int c ) {
        return c == 10 ? c + maybeExplode( d10() )
                       : c;
    }
}
