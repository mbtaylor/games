
public class KeepPage {

    private final int maxroll_;
    private final FileMapper mapper_;
    private final double width_;
    private final double height_;
    private final double gap_;

    public KeepPage( int maxroll, FileMapper mapper ) {
        maxroll_ = maxroll;
        mapper_ = mapper;
        width_ = 26;
        height_ = 20;
        gap_ = 0.05;
    }

    public void writePage() {
        out( new String[] {
            "\\documentclass[landscape]{article}",
            "\\usepackage{graphicx}",
            "\\usepackage{color}",
            "\\pagestyle{empty}",
            "\\setlength{\\textwidth}{\\paperwidth}",
            "\\setlength{\\unitlength}{1cm}",
            "\\begin{document}",
            "\\hspace*{-8cm}",
            "\\begin{picture}(" + width_ + "," + height_ + ")",
        } );
        String cellWidth = ( 1.0 - gap_ ) / maxroll_ + "\\textwidth";
        for ( int ir0 = 0; ir0 < maxroll_; ir0++ ) {
            int ir1 = ir0 + 1;
            for ( int ik0 = 0; ik0 <= ir0; ik0++ ) {
                int ik1 = ik0 + 1;
                double x = width_ * ik0 / maxroll_;
                double y = -1 + height_ - ( height_ * ir0 / maxroll_ );
                out( "  \\put(" + x + "," + y + "){"
                   + "\\includegraphics[width=" + cellWidth + "]"
                   + "{" + mapper_.getFile( ir1, ik1 ) + "}"
                   + "}" );
            }
        }
        out( new String[] {
            "\\end{picture}",
            "\\end{document}",
        } );
    }

    void out( String... txts ) {
        for ( String txt : txts ) {
            System.out.println( txt );
        }
    }

    @FunctionalInterface
    private interface FileMapper {
        String getFile( int roll, int keep );
    }

    public static void main( String[] args ) {
        FileMapper mapper =
            (r, k) -> "explode-" + r + "k" + k + ".pdf";
        new KeepPage( 5, mapper )
           .writePage();
    }
}
