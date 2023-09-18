import stilts

nsample = 100000
maxroll = 9
maxkeep = 6

def stats(explode=True):
   exp_jflag = "true" if explode else "false"
   exp_txt = "exploding" if explode else "basic"
   table = stilts.tread(":loop:%d" % nsample)
   for ir in range(0, maxroll):
      ir1 = ir + 1
      for ik in range(0, min(ir1, maxkeep)):
         ik1 = ik + 1
         col = "%s_%dk%d" % (exp_txt, ir1, ik1)
         expr = "keep(%d,%d,%s)" % (ir1, ik1, exp_jflag)
         table = table.cmd_addcol(col, expr)
      table = table.cmd_addcol("sep_%d" % ir1, "null")
   table = table.cmd_delcols("i")
   stats = ["quartile1", "median", "quartile3"]
   table = table.cmd_stats(*(["name"] + stats))
   reformat = 'formatDecimal(%s.intValue(), "#00").replaceFirst("^ *0"," ")'
   for q in stats:
      # table = table.cmd_replacecol(q, reformat % q)
      table = table.cmd_replacecol(q, q + ".intValue()")
   table.write(fmt="latex")


def write_doc():
   print('''
      \\documentclass{article}
      \\pagestyle{empty}
      \\setlength{\\textheight}{30cm}
      \\begin{document}
      \\setlength{\\leftmargin}{-4cm}
      \\vspace*{-1cm}
      \\hspace*{-3cm}''')
   stats(True)
   print("\hspace*{1.5cm}")
   stats(False)
   print('\\end{document}')

write_doc()

