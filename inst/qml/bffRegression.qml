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
import "../qml/qml_components" as BFF

Form {
	id: form
	property int framework:	Common.Type.Framework.Bayesian

	plotHeight: 340
	plotWidth:  420

	Group
	{
		DoubleField 
		{
			name:				"tStatistic";
			label:				qsTr("T-statistic")
			negativeValues:		true
		}

		IntegerField
		{
			name:				"sampleSize"
			id:					sampleSize
			label:				qsTr("Sample size")
			min:				(predictors.value == 0 || sampleSize.value == 0) ? 0 : parseInt(predictors.value) + 2
		}

		IntegerField
		{
			name:				"predictors"
			id:					predictors
			label:				qsTr("Predictors")
			max:				(predictors.value == 0 || sampleSize.value == 0) ? 2147483647 : parseInt(sampleSize.value) - 2
		}
	}

	/*VariablesForm
	{
		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight

		AvailableVariablesList
		{
			name: "allVariablesList"
		}

		AssignedVariablesList {
			name:				"tStatistic"
			title:				qsTr("T-Statistic")
			allowedColumns:		["scale"]
			singleVariable:		true
		}

		AssignedVariablesList
		{
			name:				"sampleSize"
			title:				qsTr("Sample Size")
			allowedColumns:		["ordinal", "scale"]
			singleVariable:		true
		}

		AssignedVariablesList
		{
			name:				"predictors"
			title:				qsTr("Predictors")
			allowedColumns:		["ordinal", "scale"]
			singleVariable:		true
		}
	}*/

	BFF.Analysis{}
	BFF.Priors{}
}
