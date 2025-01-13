//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//
import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP

Section
{
	property bool directionalTest:		true
	property bool oneSampleTest:		false

	expanded:	true
	title:		qsTr("Analysis")

	Group
	{
		RadioButtonGroup
		{
			name:		"alternativeHypothesis"
			title:		qsTr("Alternative Hypothesis")
			visible:	directionalTest
			RadioButton { value: "equal";		label: oneSampleTest ?  qsTr("Group 1 ≠ 0") : qsTr("Group 1 ≠ Group 2"); checked: true	}
			RadioButton { value: "greater";		label: oneSampleTest ?  qsTr("Group 1 > 0") : qsTr("Group 1 > Group 2")}
			RadioButton { value: "less";		label: oneSampleTest ?  qsTr("Group 1 < 0") : qsTr("Group 1 < Group 2")}
		}

		BayesFactorType { }

		CheckBox
		{
			name:	"bayesFactorWithPriorMode"	
			label:	qsTr("Bayes factor with prior mode")
			childrenOnSameRow:	true

			DoubleField
			{
				name:			"bayesFactorWithPriorModeValue"
				defaultValue:	1
			}
		}
	}


	Group
	{
		title: qsTr("Plots")
		Layout.rowSpan: 2

		CheckBox
		{
			checked:	true 
			name:		"plotBayesFactorFunction"
			label:		qsTr("Bayes factor function")

			CheckBox
			{
				name:		"plotBayesFactorFunctionAdditionalInfo"
				label:		qsTr("Additional info")
				checked:	true
			}
		}
		/* Disabled till implemented in the BFF package
		CheckBox
		{
			name:		"plotPriorAndPosterior"
			label:		qsTr("Prior and posterior")

			CheckBox
			{
				name:		"plotPriorAndPosteriorAdditionalInfo"
				label:		qsTr("Additional info")
				checked:	true
			}
		}
		*/
	}
}
