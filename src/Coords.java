/**
 * Created by Administrator on 12/11/2015.
 */
public class Coords {
    public double latitude;
    public double longitude;
    public Coords(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    @Override
    public String toString() {
        return latitude + " " + longitude;
    }
}
