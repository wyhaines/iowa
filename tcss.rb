require 'iowa/CSS'

a = Iowa::CSS.new
b = <<ECSS
Media.screen {
  h1 {
    color 'blue'
  }

  head_2 = h2 {
    color 'green'
    font_weight 'italic'
  }

  Id.content {
    Class.foo {
      border 3.px
      color head_2.color
    }
    font_face 'verdana'
    table {
      width 100
      Class.special {
        background_color 'grey'
      }
    }
  }

  p {
	quote {
	  font_style 'italic'
	  color 'green'
	}
  }

  p {
    universal {
      quote {
        z = font {
          style 'italic'
          weight 'bold'
        }
        color 'green'
      }
    }
  }

  universal {
    Class.smaller {font_size 85.pct}
  }

	p { p {
		font {
			size 10.pt + 2
		}}
	}
}
ECSS
a.parse b
puts a
puts "done"
