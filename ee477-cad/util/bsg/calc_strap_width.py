#!/usr/bin/python

import os
import sys
import math

m1_track_pitch = 0.8
m1_rail_width = 1.08

m5_track_pitch = 1.0
m5_min_width = 0.44
m5_min_spacing = 0.46

std_cell_height = m1_track_pitch * 8.0

# baseline offset: where routing tracks of M1 and M5 coincide.
baseline = 0.0
# finishline offset: offset of a M1 rail centerline, where the calculation stops.
finishline = 64.0

baseline_to_power_boundary_offset = 2.5

m1_rail_number = 0.0
m1_rail_centerline = baseline
print "Power strap parameters:"
while (m1_rail_centerline <= finishline):
  # M1 rail lower bound
  m1_rail_lb = m1_rail_centerline - (m1_rail_width / 2.0)
  # M1 rail upper bound
  m1_rail_ub = m1_rail_centerline + (m1_rail_width / 2.0)
  #
  # M5 lower and upper track lines to contain the strap
  m5_lower_track_number = math.floor(m1_rail_lb / m5_track_pitch)
  m5_upper_track_number = math.ceil(m1_rail_ub / m5_track_pitch)
  m5_lower_track_offset = m5_lower_track_number * m5_track_pitch
  m5_upper_track_offset = m5_upper_track_number * m5_track_pitch
  #
  # Adjust M5 track line numbers
  # Works only when m1_track_pitch <= m5_track_pitch
  if(m5_lower_track_offset + (m5_min_width / 2.0) + m5_min_spacing > m1_rail_lb):
    m5_lower_track_number -= 1.0
  if(m5_upper_track_offset - (m5_min_width / 2.0) - m5_min_spacing < m1_rail_ub):
    m5_upper_track_number += 1.0
  #
  m5_strap_lb = m5_lower_track_number + (m5_min_width / 2.0) + m5_min_spacing
  m5_strap_ub = m5_upper_track_number - (m5_min_width / 2.0) - m5_min_spacing
  m5_strap_width = m5_strap_ub - m5_strap_lb
  m5_strap_centerline = (m5_strap_ub + m5_strap_lb) / 2.0
  #
  # print m1_rail_centerline, m1_rail_lb, m1_rail_ub, m5_strap_lb, m5_strap_ub, m5_strap_width, m5_strap_centerline
  #
  # Use the following parameters for TSMC 250nm PNS script."
  print m5_strap_width, 64.0 - m5_strap_width, 64.0, m5_strap_centerline + baseline_to_power_boundary_offset
  #
  m1_rail_number += 1.0
  m1_rail_centerline = m1_rail_number * std_cell_height
