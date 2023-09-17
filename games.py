from stilts import plot2plane
import stilts

nsample = 100000
maxroll=8

basic_plot = {
   "binsize_h": 1, "barform_h": "semi_steps",
   "cumulative_h": "reverse", "normalise_h": "height",
   "xlabel": None, "ylabel": None, "grid": True, "minor": False,
   "layer_m": "function", "fexpr_m": 0.5, "color_m": "black", "thick_m": 3,
   "layer_q1": "function", "fexpr_q1": 0.25,
   "layer_q3": "function", "fexpr_q3": 0.75,
   "color_q": "black", "thick_q": 2, "dash_q": "3,3",
   "ycrowd": 0.8, "xcrowd": 2, "ymin": 0, "ymax": 1.001,
   "legend": True, "legpos": ".9,.9",
   "xpix": 600, "ypix": 300,
}
              
def write_fig(ik, explode=True):
   ik1 = ik + 1
   expl = "true" if explode else "false"
   expl_txt = "exploding" if explode else "basic"
   kwa = basic_plot.copy()
   indata = stilts.tread(":loop:%d" % nsample)
   suffixes = []
   for ir in range(ik, maxroll):
      ir1 = ir + 1
      col = "r%dk%d" % (ir1, ik1)
      print(col)
      indata = indata.cmd_addcol(col, "keep(%d,%d,%s)" % (ir1, ik1, expl));
      suffix = "_h%d" % ir1
      suffixes.append(suffix)
      kwa.update({
         "layer" + suffix: "histogram",
         "x" + suffix: col,
         "leglabel" + suffix: col + " " + expl_txt,
      })
   kwa.update({
      "in_": indata,
      "legseq": ",".join(suffixes),
      "seq": ",".join(suffixes) + ",_m,_q1,_q3",
      "xmin": 2*ik1,
      "xmax": 14*ik1,
      "transparency_h": 0.6,
   })
   stilts.plot2plane(**kwa)

write_fig(3)
 
