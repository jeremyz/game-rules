#! /bin/env ruby

require 'json'
require 'RMagick'

OUTDIR='./output/'

Dir.mkdir OUTDIR if not Dir.exists? OUTDIR

module TrackSVG
    #
    SVG_HEADER =<<-EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
        "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg xmlns="http://www.w3.org/2000/svg"
    width="23.6389in" height="15.3611in"
    viewBox="0 0 1702 1106">
    EOF
    #
    SVG_PATH =<<-EOF
<path id="__NAME__"
    fill="none" stroke="__COLOR__" stroke-width="1"
    d="__DATA__" />
    EOF
    #
    def gen_svg track
        svg = SVG_HEADER
        svg << track_ext_svg(track).sub(/__COLOR__/,'black')
        svg << track_int_svg(track).sub(/__COLOR__/,'black')
        svg << track_mid_right_svg(track).sub(/__COLOR__/,'black')
        svg << track_mid_left_svg(track).sub(/__COLOR__/,'black')
        svg << lane_0_svg(track).sub(/__COLOR__/,'white')
        svg << lane_1_svg(track).sub(/__COLOR__/,'white')
        svg << lane_2_svg(track).sub(/__COLOR__/,'white')
        svg << lane_3_svg(track).sub(/__COLOR__/,'green')
        svg << track_segs_svg(track).sub(/__COLOR__/,'black')
        svg << paddocks_segs_svg(track).sub(/__COLOR__/,'black')
        svg << '</svg>'
        svg
    end
    #
    def track_ext_svg track
        svg = nil
        track.select{ |t| t['lane']==0 }.each_with_index do |t,i|
            pts = t['paths']['left']
            svg = "M #{pts[0]},#{pts[1]}\nC" if i == 0
            svg += " #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}\n"
        end
        svg += ' Z'
        SVG_PATH.sub(/__NAME__/,'track-ext').sub(/__DATA__/,svg)
    end
    #
    def track_int_svg track
        svg = nil
        track.select{ |t| t['lane']==2 }.each_with_index do |t,i|
            pts = t['paths']['right']
            svg = "M #{pts[0]},#{pts[1]}\nC" if i == 0
            svg += " #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}\n"
        end
        svg += ' Z'
        SVG_PATH.sub(/__NAME__/,'track-int').sub(/__DATA__/,svg)
    end
    #
    def track_mid_left_svg track
        svg = nil
        track.select{ |t| t['lane']==1 }.each_with_index do |t,i|
            pts = t['paths']['left']
            svg = "M #{pts[0]},#{pts[1]}\nC" if i == 0
            svg += " #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}\n"
        end
        svg += ' Z'
        SVG_PATH.sub(/__NAME__/,'track-mid-ext').sub(/__DATA__/,svg)
    end
    #
    def track_mid_right_svg track
        svg = nil
        track.select{ |t| t['lane']==1 }.each_with_index do |t,i|
            pts = t['paths']['right']
            svg = "M #{pts[0]},#{pts[1]}\nC" if i == 0
            svg += " #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}\n"
        end
        svg += ' Z'
        SVG_PATH.sub(/__NAME__/,'track-mid-int').sub(/__DATA__/,svg)
    end
    #
    def track_segs_svg track
        svg = ''
        track.each_with_index do |t,i|
            next if t['lane'] > 2
            l = t['paths']['left']
            r = t['paths']['right']
            next if r.nil? or l.nil?
            svg += "M #{l[0]},#{l[1]} L #{r[0]},#{r[1]}\n"
        end
        SVG_PATH.sub(/__NAME__/,'track-segs').sub(/__DATA__/,svg)
    end
    #
    def paddocks_segs_svg track
        svg = ''
        track.each_with_index do |t,i|
            next if t['lane'] != 3
            l = t['paths']['left']
            r = t['paths']['right']
            next if r.nil? or l.nil?
            svg += "M #{l[0]},#{l[1]} L #{r[0]},#{r[1]}\n"
        end
        SVG_PATH.sub(/__NAME__/,'paddocks-segs').sub(/__DATA__/,svg)
    end
    #
    def lane_0_svg track; lane track, 0, 'lane-0'; end
    def lane_1_svg track; lane track, 1, 'lane-1'; end
    def lane_2_svg track; lane track, 2, 'lane-2'; end
    def lane_3_svg track; lane(track, 3, 'lane-3').sub(/Z/,''); end
    #
    def lane track, n, t
        svg = nil
        track.select{ |t| t['lane']==n }.each_with_index do |t,i|
            pts = t['paths']['lane']
            svg = "M #{pts[0]},#{pts[1]}\nC" if i == 0
            svg += " #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}\n"
        end
        svg += ' Z'
        SVG_PATH.sub(/__NAME__/,t).sub(/__DATA__/,svg)
    end
end

module TrackDraw
    #
    IMG_WIDTH = 1702
    IMG_HEIGHT = 1106
    #
    def draw_info image, track, what, idx=nil
        draw = Magick::Draw.new
        # draw.pointsize = 20
        draw.text_align(Magick::CenterAlign)
        track.each do |tile|
            draw.fill(tile_color(tile))
            w = tile[what]
            w = w[idx] unless idx.nil?
            draw.text( *tile['center'], w.to_s );
        end
        draw.draw(image)
    end
    #
    def draw_car_pos image, track
        draw = Magick::Draw.new
        track.each do |t|
            # center point
            pts = t['center']
            draw.fill(tile_color(t))
            draw.circle( pts[0], pts[1], pts[0], pts[1]+1 )
            # direction vector
            l = 10
            r = t['radians']
            y = Math.sin(r) * l
            x = Math.cos(r) * l
            draw.line( pts[0], pts[1], pts[0]+x, pts[1]+y )
        end
        draw.draw(image)
    end
    #
    def draw_lanes image, track
        draw = Magick::Draw.new
        draw.stroke_opacity(1)
        track.each do |t|
            pts = t['paths']['lane']
            # paths
            draw.fill_opacity(0)
            draw.stroke(tile_color(t))
            draw.path("M #{pts[0]},#{pts[1]} C #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}")
            # control points
            draw.fill('black')
            draw.fill_opacity(1)
            draw.point( pts[0], pts[1] )
            draw.point( pts[2], pts[3] )
            draw.point( pts[4], pts[5] )
            draw.point( pts[6], pts[7] )
        end
        draw.draw(image)
    end
    #
    def draw_track image, track
        draw = Magick::Draw.new
        draw.fill_opacity(0)
        draw.stroke_opacity(1)
        track.each do |t|
            if t['lane'] == 0
                pts = t['paths']['left']
            elsif t['lane'] == 2
                pts = t['paths']['right']
            else
                pts = nil
            end
            if pts
                draw.stroke(tile_color(t))
                draw.path("M #{pts[0]},#{pts[1]} C #{pts[2]},#{pts[3]} #{pts[4]},#{pts[5]} #{pts[6]},#{pts[7]}")
            end
        end
        draw.draw(image)
    end
    #
    def draw_tiles image, track
        draw = Magick::Draw.new
        track.each do |t|
            l = t['paths']['left']
            r = t['paths']['right']
            next if r.nil? or l.nil?
            draw.fill(tile_color(t))
            draw.line(l[0], l[1], r[0],  r[1])
            # draw.line(l[-2], l[-1], r[-2],  r[-1])
        end
        draw.draw(image)
    end
    #
    private
    #
    def tile_color tile
        case tile['type']
        when 0
            'white'
        when 1
            'red'
        when 2
            'green'
        else
            'blue'
        end
    end
    #
    def get_img input=nil
        if input.nil?
            Magick::Image.new(IMG_WIDTH,IMG_HEIGHT) { self.background_color = "none" }
        else
            Magick::Image::read(input).first
        end
    end
end

class Track
    #
    include TrackDraw
    include TrackSVG
    #
    LANE_0 = 0
    LANE_1 = 1
    LANE_2 = 2
    STANDS_LANE = 3
    STANDS = 4
    CELL_WIDTH = 9.0
    #
    attr_reader :track
    def initialize path
        @json_path = path
        @jpg_path = @json_path.split('.')[0..-2].join+'.jpg'
        @base_path = OUTDIR+@json_path.split('.')[0..-2].join
        process!
    end
    #
    def json
        JSON.pretty_generate(@track)
        # JSON.dump(@track)
    end
    #
    def write_json
        open(@base_path+'.json','w') { |f| f << json }
    end
    #
    def draw_ sym
        printf '.'
        send sym
    end
    #
    def svg_
        open(@base_path+'-track.svg','w') { |f| f << gen_svg(@track) }
    end
    #
    def draw_no; do_draw_info 'no'; end
    def draw_next_in; do_draw_info 'next_in'; end
    def draw_distance; do_draw_info 'distance'; end
    def draw_lane; do_draw_info 'lane'; end
    def draw_turn; do_draw_info 'turn_idx'; end
    def draw_max_gear_0; do_draw_gear 0; end
    def draw_max_gear_1; do_draw_gear 1; end
    def draw_max_gear_2; do_draw_gear 2; end
    def draw_max_gear_3; do_draw_gear 3; end
    def draw_positions; do_draw :draw_car_pos, '-positions.png'; end
    def draw_lanes_paths; do_draw :draw_lanes, '-lane-paths.png'; end
    def draw_track_paths; do_draw :draw_track, '-track.png'; end
    def draw_tiles_paths; do_draw :draw_tiles, '-tiles.png'; end
    #
    private
    #
    def do_draw sym, str
        img = get_img @jpg_path
        send(sym, img, @track)
        img.write @base_path+str
    end
    #
    def do_draw_info info
        img = get_img @jpg_path
        draw_info img, @track, info
        img.write @base_path+"-#{info}.png"
    end
    #
    def do_draw_gear x
        img = get_img @jpg_path
        draw_info img, @track, 'max_gear', x
        img.write @base_path+"-max-gear-#{x}.png"
    end
    #
    def iterate_lane lane, i, cpt
        loop do
            break if i.nil?
            t = @orig.delete_at i
            t['lane'] = lane
            n = t['no']
            @conv[n] = cpt
            cpt += 1
            @track << t
            i = @orig.index { |t| t['in_front_of'] == n }
        end
        cpt
    end
    #
    def iterate_stands_lane lane, cpt
        @orig.select { |t| t['type']==2 } .sort { |a,b| a['no']<=>b['no'] } .each do |t|
            @orig.delete t
            t['lane'] = lane
            n = t['no']
            @conv[n] = cpt
            cpt += 1
            @track << t
        end
        cpt
    end
    #
    def iterate_stands lane, cpt
        @orig.sort { |a,b|
            r = a['type']<=>b['type']
            r = a['no']<=>b['no'] if r==0
            r
        } .each do |t|
            @orig.delete t
            t['lane'] = lane
            n = t['no']
            @conv[n] = cpt
            cpt += 1
            @track << t
        end
        cpt
    end
    #
    def adj_to n0, n1
        @orig.index { |t|
            a = t['adjacents']
            next if a.nil?
            ( a.include? n0 and a.include? n1 )
        }
    end
    #
    def apply_conv!
        @track.each do |t|
            t['no'] = @conv[t['no']]
            t['in_front_of'] = @conv[t['in_front_of']]
            ['adjacents','leads_to'].each do |attr|
                a = t[attr] || []
                a.each_with_index { |j,i| a[i] = @conv[j] }
            end
        end
    end
    #
    def reorder!
        @conv = {}
        @track = []
        # lane 0, starts in front of pole position
        n = @orig[ @orig.index { |t| t['grid_position'] == 0 } ]['no']
        i = @orig.index { |t| t['in_front_of'] == n }
        cpt = 0
        cpt = iterate_lane LANE_0, i, cpt
        # lane 1, starts adjacent to 0 and 1
        n0 = @track[0]['no']
        n1 = @track[1]['no']
        i = adj_to n0, n1
        n0 = @orig[i]['no']
        cpt = iterate_lane LANE_1, i, cpt
        # lane 2, start adjacent to first and last of lane 1
        n1 = @track[-1]['no']
        i = adj_to n0, n1
        cpt = iterate_lane LANE_2, i, cpt
        # stands lane
        cpt = iterate_stands_lane STANDS_LANE, cpt
        # stands
        cpt = iterate_stands STANDS, cpt
        #
        apply_conv!
        #
        puts '  ERROR: original track is not empty after reordering' if not @orig.empty?
    end
    #
    def trans_pts l, d, x1, y1, x2, y2
        dx = x2 - x1
        dy = y2 - y1
        f = l / Math.sqrt(dx*dx + dy*dy)
        dx *= f
        dy *= f
        if d
            [ x1-dy, y1+dx, x2-dy, y2+dx ]
        else
            [ x1+dy, y1-dx, x2+dy, y2-dx ]
        end
    end
    #
    def compute_paths!
        # FIXME: share the same coords between adjacents
        @track.each_with_index do |t,i|
            pts = t['path']
            t.delete 'path'
            t['paths'] = {}
            # back to front [pt ctrl ctrl pt]
            t['paths']['lane'] = [pts[2], pts[3], pts[6], pts[7], pts[4], pts[5], pts[0], pts[1]]
            next if t['type'] > 2
            tx1, ty1, tcx1, tcy1 = trans_pts CELL_WIDTH, true, pts[0], pts[1], pts[4], pts[5]
            bx1, by1, bcx1, bcy1 = trans_pts CELL_WIDTH, false, pts[2], pts[3], pts[6], pts[7]
            bx2, by2, bcx2, bcy2 = trans_pts CELL_WIDTH, true, pts[2], pts[3], pts[6], pts[7]
            tx2, ty2, tcx2, tcy2 = trans_pts CELL_WIDTH, false, pts[0], pts[1], pts[4], pts[5]
            t['paths']['left'] = [bx1, by1, bcx1, bcy1, tcx1, tcy1, tx1, ty1]
            t['paths']['right'] = [bx2, by2, bcx2, bcy2, tcx2, tcy2, tx2, ty2]
        end
    end
    #
    def process!
        @orig = JSON.parse(File.read(@json_path))
        reorder!
        compute_paths!
    end
end

################################################################3
puts '  load and process JSON'
track = Track.new ARGV[0]
puts '  write JSON'
track.write_json
printf '  draw '
track.draw_ :draw_no
track.draw_ :draw_lane
track.draw_ :draw_turn
track.draw_ :draw_next_in
track.draw_ :draw_distance
track.draw_ :draw_max_gear_0
track.draw_ :draw_max_gear_1
track.draw_ :draw_max_gear_2
track.draw_ :draw_max_gear_3
track.draw_ :draw_positions
track.draw_ :draw_lanes_paths
track.draw_ :draw_track_paths
track.draw_ :draw_tiles_paths
track.svg_
printf "\n"

